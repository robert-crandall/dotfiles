# adversarial-review

Skill for getting a hostile second opinion on a plan, diff, design, or decision before committing to it. Runs the rubber-duck agent on **GPT-5.5 high** so the critique is genuinely independent of the host Claude agent rather than another instance of the same model agreeing with itself.

The two failure modes this skill exists to prevent:

1. **Shipping a regression because nobody pushed back.** The default rubber-duck pass is too cooperative for cleanup work, refactors, and design pivots — where the right answer is usually "delete more, simplify more" rather than "yes that looks fine."
2. **Burning iteration cycles on CCR comments that all point at the same root cause.** When CCR keeps coming back with the same class of feedback, the underlying mental model is wrong; an adversarial pass surfaces that earlier and cheaper.

See `SKILL.md` for the full workflow, `references/prompts.md` for ready-to-paste prompt templates, and `references/catches.md` for known high-value catches by work type.

Always uses `model: "gpt-5.5"` for the rubber-duck override. Default model = your host Claude = same lineage = polite agreement. Different lineage = real disagreement.
## Installation

Installed with the rest of the dotfiles - `install.sh` symlinks `copilot-skills/` to
`~/.copilot/skills`, so this skill is picked up automatically.
