workflow "deploy" {
  on = "push"
  resolves = ["docker://khs1994/gitbook"]
}

action "docker://khs1994/gitbook" {
  uses = "docker://khs1994/gitbook"
  secrets = ["GITHUB_TOKEN"]
  env = {
    GIT_USERNAME = "khs1994"
    GIT_USEREMAIL = "khs1994@khs1994.com"
    GIT_BRANCH = "gh-pages"
  }
}
