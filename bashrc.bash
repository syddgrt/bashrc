$ cat ~/.bashrc

# .bashrc

# ================================
# Syed's Homelab Bashrc
# WSL Fedora + K3s Control Plane
# ================================

# Kubeconfig
export KUBECONFIG="$HOME/.kube/config"

# ---------- kubectl ----------
alias k='kubectl'

# Get resources
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kgn='kubectl get nodes'
alias kgs='kubectl get svc'
alias kgd='kubectl get deploy'
alias kgi='kubectl get ingress'
alias kgns='kubectl get ns'
alias kx='kubectl config current-context'

# Wide output
alias kgpw='kubectl get pods -o wide'
alias kgnw='kubectl get nodes -o wide'

# Describe
alias kdp='kubectl describe pod'
alias kdn='kubectl describe node'
alias kdd='kubectl describe deploy'

# Logs
alias kl='kubectl logs'
alias klf='kubectl logs -f'

# Exec
alias ke='kubectl exec -it'

# Apply / Delete
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'
alias kd='kubectl delete'

# Rollout
alias krs='kubectl rollout status'
alias krr='kubectl rollout restart deployment'

# Context
alias kc='kubectl config current-context'

# ---------- Change Namespace ----------
cns() {
    if [ -z "$1" ]; then
        echo "Usage: cns <namespace>"
        echo
        kubectl get ns
        return 1
    fi

    if kubectl get namespace "$1" >/dev/null 2>&1; then
        kubectl config set-context --current --namespace="$1" >/dev/null
        echo "✓ Namespace switched to '$1'"
    else
        echo "✗ Namespace '$1' does not exist."
        echo
        kubectl get ns
        return 1
    fi
}

# ---------- Drain / Uncordon ----------
alias kdrain='kubectl drain --ignore-daemonsets --delete-emptydir-data'
alias kunc='kubectl uncordon'

# ---------- SSH Homelab ----------
alias pi1='ssh syedpi1'
alias pi2='ssh syedpi2'
alias arch='ssh arch'

# ---------- System ----------
alias cls='clear'
alias ll='ls -lah'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'

# journalctl
alias jctl='sudo journalctl -xe'
alias jk3s='sudo journalctl -u k3s -f'
alias jagent='sudo journalctl -u k3s-agent -f'

# systemd
alias sreload='sudo systemctl daemon-reload'
alias srestart='sudo systemctl restart'
alias sstatus='systemctl status'

# Networking
alias myip="ip route get 1.1.1.1 | awk '{print \$7}'"

# ---------- Git Branch ----------
parse_git_branch() {
    git branch 2>/dev/null | sed -n 's/* \(.*\)/(\1)/p'
}

# ---------- Kubernetes Context + Namespace ----------
parse_kube() {
    command -v kubectl >/dev/null 2>&1 || return

    local ctx ns
    ctx=$(kubectl config current-context 2>/dev/null) || return
    ns=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)

    [ -z "$ns" ] && ns="default"

    echo "[$ctx/$ns]"
}

# ---------- Pretty Prompt ----------
PS1='\[\e[38;5;51m\]syed@wsl-fedora\[\e[0m\] \[\e[38;5;229m\]\w\[\e[38;5;214m\]$(parse_git_branch)\[\e[38;5;46m\]$(parse_kube)\[\e[0m\]\n$ '

# ---------- Source Global Bash ----------
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# ---------- User PATH ----------
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment if you dislike systemctl pager
# export SYSTEMD_PAGER=

# ---------- Load Extra Bash Scripts ----------
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        [ -f "$rc" ] && . "$rc"
    done
fi
unset rc

# ---------- Conda ----------
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("$HOME/miniconda3/bin/conda" 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
