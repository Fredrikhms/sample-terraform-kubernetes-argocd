
ls:
  tofu state list

tofu: 
  tofu apply --auto-approve

argocd:
  echo "url: http://localhost:8080"
  echo "user: admin"
  echo "pass: $(argocd admin initial-password -n argocd)"
  kubectl port-forward svc/argocd-server -n argocd 8080:443
