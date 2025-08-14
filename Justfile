
ls:
  tofu state list

tofu: 
  tofu apply --auto-approve

tofu-rebuild:
  tofu destroy --target=helm_release.argocd --auto-approve && just tofu

argocd:
  echo "url: http://localhost:8080"
  echo "user: admin"
  echo "pass: $(argocd admin initial-password -n argocd)"
  kubectl port-forward svc/argocd-server -n argocd 8080:443

helm: 
  helm get manifest argocd -n argocd  

helm-inpect-volumes: 
  just helm | yq  '.spec | select( . != null) | .template | select ( . != null) | .spec.volumes' 

sync: #https://github.com/argoproj/argo-cd/discussions/9912#discussioncomment-9981095
  argocd app sync cluster-config --local ./argocd/manifests/cluster
