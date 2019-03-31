workflow "New workflow" {
  on = "push"
  resolves = ["docker://khs1994/gitbook"]
}

action "docker://khs1994/gitbook" {
  uses = "docker://khs1994/gitbook"
}
