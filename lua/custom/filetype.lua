vim.filetype.add {
  extension = {
    mdx = 'mdx',
    tfvars = 'terraform-vars',
    gotmpl = 'gotmpl',
  },
  filename = {
    ['go.work'] = 'gowork',
    ['go.work.sum'] = 'gowork',
    ['docker-compose.yml'] = 'yaml.docker-compose',
    ['docker-compose.yaml'] = 'yaml.docker-compose',
    ['compose.yml'] = 'yaml.docker-compose',
    ['compose.yaml'] = 'yaml.docker-compose',
    ['.gitlab-ci.yml'] = 'yaml.gitlab',
    ['.gitlab-ci.yaml'] = 'yaml.gitlab',
  },
  pattern = {
    ['.*/roles/.*/tasks/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/playbooks/.*%.ya?ml'] = 'yaml.ansible',
    ['.*ansible.*%.ya?ml'] = 'yaml.ansible',
    ['.*/values.*%.ya?ml'] = 'yaml.helm-values',
    ['.*/values/.*%.ya?ml'] = 'yaml.helm-values',
    ['.*%.tfvars%.json'] = 'terraform-vars',
  },
}
