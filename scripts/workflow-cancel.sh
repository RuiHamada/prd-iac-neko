gh run list

gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/RuiHamada/prd-iac-neko/actions/runs/17050417348/force-cancel