#!/bin/bash
# ==============================================================================
# Evaluator Contract Script — KMS AI Agent for Automotive Documentation
#
# Usage:
#   ./scripts/run.sh --input <input_dir> --output <output_file>
#
# This script is called by the hackathon automated scoring system.
# It must parse --input and --output flags and produce valid JSON output.
# ==============================================================================

set -euo pipefail

INPUT_DIR=""
OUTPUT_FILE=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --input)  INPUT_DIR="$2"; shift ;;
        --output) OUTPUT_FILE="$2"; shift ;;
        *)        echo "Error: Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

if [ -z "$INPUT_DIR" ] || [ -z "$OUTPUT_FILE" ]; then
    echo "Usage: ./scripts/run.sh --input <input_dir> --output <output_file>"
    exit 1
fi

echo "=========================================================="
echo "  KMS AI Agent — Offline Evaluation"
echo "  Input : $INPUT_DIR"
echo "  Output: $OUTPUT_FILE"
echo "=========================================================="

mkdir -p "$(dirname "$OUTPUT_FILE")"

cd "$(dirname "$0")/.."

python -m pipelines.solve_problem --input "$INPUT_DIR" --output "$OUTPUT_FILE"

echo "✅ Evaluation completed. Results: $OUTPUT_FILE"
