gh repo create proxmox-homelab --public
gh auth status
git remote set-url origin https://<token>@github.com/diogofrj/proxmox-homelab.git

git add .
git commit -m "Initial commit"
git push -u origin main
```