import numpy as np, torch
from transformers import AutoTokenizer, AutoModelForCausalLM

dev = "cuda" if torch.cuda.is_available() else "cpu"
tok = AutoTokenizer.from_pretrained("gpt2")
lm = AutoModelForCausalLM.from_pretrained("gpt2").to(dev).eval()


def surprisal_batch(contexts, target):
    """-log2 P(target | context) in bits for each context (a list of words)."""
    tgt = tok.encode(" " + target)
    seqs = [[tok.bos_token_id] + (tok.encode(" ".join(c)) if c else []) + tgt
            for c in contexts]
    lens = torch.tensor([len(s) for s in seqs])
    ids = torch.full((len(seqs), int(lens.max())), tok.eos_token_id)
    for b, s in enumerate(seqs):
        ids[b, :len(s)] = torch.tensor(s)
    mask = (torch.arange(ids.shape[1])[None, :] < lens[:, None]).long()
    with torch.no_grad():
        logp = torch.log_softmax(lm(ids.to(dev), attention_mask=mask.to(dev)).logits, dim=-1)
    out = []
    for b, s in enumerate(seqs):
        n = len(s) - len(tgt)  # position of the first target token
        out.append(-sum(logp[b, n - 1 + j, t].item() for j, t in enumerate(tgt)) / np.log(2))
    return np.array(out)


rng = np.random.default_rng(0)


def sample_memory(context_words, lam, D=20):
    """Keep each of the last D words with probability exp(-d/lam), d = distance to target."""
    ctx = context_words[-D:]
    d = np.arange(len(ctx), 0, -1)
    keep = rng.random(len(ctx)) < np.exp(-d / lam)
    return [w for w, k in zip(ctx, keep) if k]


def full_surprisal(context_words, target, W=200):
    return surprisal_batch([context_words[-W:]], target)[0]


def lossy_surprisal(context_words, target, lam, S=20, D=20):
    return surprisal_batch([sample_memory(context_words, lam, D) for _ in range(S)],
                           target).mean()


if __name__ == "__main__":
    ctx = "Bob threw the old trash".split()
    print(full_surprisal(ctx, "out"), lossy_surprisal(ctx, "out", lam=2))