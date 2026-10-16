---
name: local-llm-deployment-planning
description: Plan and compare local LLM inference deployments for a single user issuing multiple requests. Use when selecting models, quantization, inference frameworks, or RAM/SSD offloading strategies for Apple Silicon on macOS or NVIDIA GPUs on Ubuntu, and when producing deployable recipes within hardware and performance budgets.
---

# Local LLM Deployment Planning

Produce evidence-based deployment recipes for one user's own computer. Assume a single user issuing multiple requests, including concurrent requests; do not introduce multi-user serving requirements.

## Decision Order

1. Meet hardware capacity, required input context, output length, concurrency, latency, and model quality requirements.
2. Among feasible candidates, optimize throughput for that workload. Evaluate aggregate throughput alongside per-request responsiveness.
3. When performance goals are met, prefer less model quality loss. For the same base model and comparable quantization methods, prefer 6-bit over 4-bit if both meet the requirements. Compare different models or quantization methods using quality evidence, not bit width alone.

Never reduce required context, output length, or concurrency to make a candidate appear feasible or fast. Do not substitute an impressive throughput number for acceptable end-to-end latency.

## Establish the Workload and Platform

Extract the following from the conversation and available hardware information:

- Target model or task, required model quality, and whether model substitutions are allowed.
- Hardware already owned, permitted upgrades, and budget: accelerator model/count, VRAM or unified memory, host RAM, and available SSD capacity and performance.
- Typical and maximum input tokens, expected and maximum output tokens, number of simultaneous requests, and request arrival pattern.
- Acceptable time to first token (TTFT), end-to-end latency, and target throughput; include cold-start tolerance if relevant.
- Preferred or required inference frameworks and deployment methods.

Ask only for missing information that would change the recommendation. For other gaps, state concrete assumptions and proceed with research. Do not silently treat an assumption as a confirmed requirement. Keep typical and maximum workloads visible throughout the comparison.

Apply the user's platform convention: GPU, NVIDIA, RTX, or CUDA means NVIDIA GPUs on Ubuntu; MLX, Apple Silicon, or Apple M-series means macOS on Apple hardware. When no NVIDIA/GPU signal is present, use the Apple/macOS path. If signals conflict, resolve the intended hardware before choosing a platform. Never propose Windows recipes.

## Research Deployable Recipes

Search the web before recommending candidates. Prefer official framework documentation, release notes, model cards, published packages/images, and reproducible public deployment reports. Check current support for the exact model architecture, weight format, quantization method, hardware, concurrency, and offloading features under consideration.

Use released public software, official installers, published packages, GitHub Releases, or platform-appropriate container images. Public nightly builds are acceptable; identify their exact build or revision. Pin versions or image digests instead of relying solely on mutable tags such as latest. Do not require framework source modifications, custom patches, adaptation layers, or custom kernels unless the user explicitly requests them. Use only documented configuration options supported by the chosen version.

Attach source links to compatibility claims, setup instructions, and performance evidence. Record benchmark conditions: hardware, software version, model, quantization, input/output lengths, concurrency, caching, and warm/cold state. Label each result as public measurement, estimate, or pending local validation. Explain material differences between published conditions and the user's workload; do not present cross-hardware figures as measurements of the user's machine. If evidence is unavailable, state the specific missing measurement and how to obtain it without inventing a number.

## Actively Evaluate RAM and SSD Offloading

Allow and encourage RAM offloading and SSD offloading. Include them in the candidate search even when the full model cannot reside in accelerator memory. Prefer an offloaded candidate when it better satisfies the decision order, including preserving model quality. Retain the same latency and workload requirements used for fully resident candidates.

- Identify exactly what is offloaded: weights, KV cache, or other runtime state; where it resides; and whether execution also moves to the CPU.
- Verify that the public framework version supports the proposed mechanism on the target platform. Distinguish configured offloading from model files merely stored on SSD, memory mapping, and uncontrolled operating-system swap.
- Account for transfer bandwidth, repeated reads, prefill and decode behavior, cold versus warm caches, and concurrent requests. Do not equate fitting in storage with meeting the latency target.
- For SSD-backed execution, identify the active disk footprint, expected read/write behavior, and required free space. Include write volume or endurance implications when the mechanism writes frequently.
- On Apple hardware, account for a shared unified-memory pool; do not add GPU allocations and RAM as independent physical capacities or describe unified memory as separate host-RAM offloading. Evaluate the actual memory placement and SSD mechanism supported by the framework.

## Compare Up to Three Viable Candidates

Seek three meaningfully different recipes, such as different model quality/performance tradeoffs, frameworks, or residency/offloading strategies. Return fewer when fewer satisfy the constraints; do not fill the table with infeasible alternatives. State concrete rejection reasons for excluded paths. If none meets all requirements, identify the limiting requirement and offer explicit changes for the user to choose rather than silently relaxing it.

Lead with the recommended recipe and why it wins under the decision order. Include a candidate table with these fields; split it into linked tables using the same candidate labels if necessary for readability:

| Candidate and pinned software | Model and quantization | Residency / offloading | Peak VRAM or unified memory | Peak host RAM | SSD footprint | Model quality loss | Performance expectation | Evidence and tradeoffs |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |

For each candidate:

- Include weights, KV cache at required context/concurrency, runtime buffers, and explicit system headroom in memory estimates. Report units and estimation assumptions. For Apple, report unified memory once and mark host RAM as the same shared pool.
- Break down SSD use into model files, runtime or image, active offload/cache, and temporary installation/conversion space where applicable. Report steady-state and peak installation footprints; do not double-count shared files or treat memory mapping as a second on-disk copy.
- Compare model quality loss against a named baseline using relevant evaluations or clearly labeled qualitative expectations. Do not invent percentage losses from bit width. Use model quality consistently rather than an ambiguous precision score.
- Compare expected TTFT, decode tokens per second per request, aggregate throughput at the requested concurrency, and end-to-end latency for the stated input/output workload. Include tail latency when evidence is available. Separate cold and warm behavior when loading or offloading changes the result.
- Give a concrete fit verdict against each hard requirement. A candidate whose feasibility depends on unmeasured performance must be labeled conditional and include the measurement needed to decide; it must not be counted as verified feasible.

## Provide Deployment and Verification Steps

For each retained recipe, provide the exact model artifact, public software version/build, source links, installation or container steps suitable for its platform, documented runtime settings, and a minimal inference request. Explain any required public model conversion step and its resource cost. Do not assume Docker is the right installation method on every platform.

Give a local verification procedure that uses the user's actual context, output length, and simultaneous-request count. Measure TTFT, per-request decode speed, aggregate throughput, end-to-end latency, peak memory, SSD usage, and a representative quality check against the named baseline. Exercise both typical and maximum requests, and cold/warm runs when relevant. State pass/fail criteria from the user's targets and how failed measurements affect the recommendation.

Deliver the recommendation, comparison, deployment steps, and verification procedure without automatically installing packages, downloading models, or changing system configuration. Execute deployment only when the user authorizes it.
