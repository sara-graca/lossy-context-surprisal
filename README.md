# Lossy-context surprisal on naturalistic and controlled data

Sara Graça and Tori Baral

Lossy-context surprisal adds forgetting to GPT-2 surprisal: context words are randomly erased, each with probability depending on its distance to the target word and on a forgetting rate λ (the smaller λ, the more forgetting). We fit it to self-paced reading times and test whether the same λ fits best on naturalistic text (**Natural Stories**) and on controlled sentences (**StructuralCost**), where the subject–verb distance is manipulated.

## Repository structure

```
lossy-context-surprisal/
├── README.md
├── report.pdf                 final report
├── src/
│   └── surprisal.py           GPT-2 full and lossy surprisal (functions given in the project)
├── notebooks/
│   ├── ns_setup.ipynb         Exercise 1: Natural Stories predictors -> results/ns_verbs.csv
│   ├── sc_setup.ipynb         Exercise 2: StructuralCost predictions  -> results/sc_verbs.csv
│   └── ns_sc_loglik.ipynb     Exercises 3-4: ΔlogLik plots, best λ, condition coefficients
├── r_files/
│   ├── ns_loglik_anova_distance.r   Exercise 3: models on Natural Stories
│   ├── comparison.r                 Exercise 3: same models on verbs with distance >= 4
│   └── sc_loglik_anova_distance.r   Exercise 4: models on StructuralCost
├── data/                      raw data (not in the repository, see below)
├── results/                   computed surprisals, regression tables and R outputs
├── figures/                   figures used in the report
└── pixi.toml                  Python and R environment
```

## Setup

The environment is managed with [pixi](https://pixi.sh):

```bash
pixi install
```


## Data

The raw data is not included. From the repository root:

- **Natural Stories**:
  ```bash
  git clone --depth 1 https://github.com/languageMIT/naturalstories.git data/naturalstories
  ```
- **StructuralCost**: download `StructuralCost_critical.csv` and `StructuralCost_control.csv` from https://nakala.fr/10.34847/nkl.7c467lyv and put them in `data/structuralcost/`.

## How to reproduce the results

Run in this order. The slow computations are saved in `results/` and are skipped by default when the files already exist (flags `RUN_LOSSY`, `RUN_SURP`, `RUN_SURP_PREV`, `RUN_EXTRA` at the top of the corresponding cells).

1. **`notebooks/ns_setup.ipynb`** Full surprisal of every word, lossy surprisal for λ = 1, 2, 4, 8 (run on a Colab GPU with the `lossy_story` function of this notebook), λ = 16 and 32 for the verbs and the words before them only, subject–verb distances from the UD parse, and the regression table `results/ns_verbs.csv`.
2. **`notebooks/sc_setup.ipynb`** Surprisal of the main verb of each sentence and of the word before it, predictions by condition, and the regression table `results/sc_verbs.csv`.
3. **R scripts**, from the repository root:
   ```bash
   pixi run Rscript r_files/ns_loglik_anova_distance.r > results/ns_output.txt
   pixi run Rscript r_files/comparison.r > results/ns_long_output.txt
   pixi run Rscript r_files/sc_loglik_anova_distance.r > results/sc_output.txt
   ```
   They write the log-likelihoods (`*_loglik.csv`), the condition coefficients (`sc_cond_coefs.csv`), and print the likelihood-ratio tests and coefficients.
4. **`notebooks/ns_sc_loglik.ipynb`** ΔlogLik per observation, best λ for each dataset, and the figures.

## Main choices

- **Seeds**: lossy surprisal is random. Instead of one random generator for the whole run, a new generator is created before each word, with a seed built from its story (or sentence), position and λ, so that results are identical even if a computation is restarted.
- **Distance**: number of displayed words between the subject and the verb (punctuation never counted).
- **Frequency**: `wordfreq` (Zipf scale) for both datasets; length counts letters and digits.
- **Reading times**: kept between 100 and 3,000 ms in both datasets; predictors are z-scored on each verb table.

## Main results

- **StructuralCost**: clear optimum at λ = 8, which fits better than full surprisal.
- **Natural Stories**: the ΔlogLik curve is almost flat for λ ≥ 2, and full surprisal fits clearly better than any lossy model. On the verbs with a distance of 4 or more only, the best value is λ = 2.
- Lossy surprisal explains only 14% of the distance effect in StructuralCost, and neither the PP conditions nor the advantage of doubly embedded relative clauses.

The full analysis is in the [report](report.pdf).
