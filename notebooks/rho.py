import os
os.environ["KMP_DUPLICATE_LIB_OK"] = "TRUE"   # fix for the PyTorch/numpy clash on Windows

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from IPython.display import Image

D = 20
d = np.arange(1, 31)

fig, ax = plt.subplots(figsize=(8, 5))
for lam in [1, 2, 4, 8]:
    ax.plot(d, np.exp(-d / lam), marker="o", markersize=4, label=f"λ = {lam}")
ax.axhline(0.5, color="gray", linestyle="--", linewidth=1)
ax.text(30, 0.52, "ρ = 1/2", ha="right", color="gray")
ax.axvline(D + 0.5, color="black", linewidth=1)
ax.axvspan(D + 0.5, d.max() + 0.5, color="gray", alpha=0.15)
ax.text(D + 1, 0.9, "outside the 20-word\ncontext: always dropped", fontsize=9)
ax.set_xlabel("distance d (words before the target)")
ax.set_ylabel("probability of keeping the word  ρ(d) = exp(−d/λ)")
ax.set_xlim(0.5, d.max() + 0.5)
ax.set_ylim(0, 1.02)
ax.set_title("Probability that a context word is remembered")
ax.legend()
plt.tight_layout()

os.makedirs("figures", exist_ok=True)
plt.savefig("figures/rho_curves.pdf")             # for the report
plt.savefig("figures/rho_curves.png", dpi=150)    # to display here
Image("figures/rho_curves.png")