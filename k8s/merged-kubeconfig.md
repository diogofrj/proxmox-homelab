Como usar o script:
1. Salve o script em um arquivo (por exemplo, merge-kubeconfig.sh)
2. Dê permissão de execução:
```bash
chmod +x merge-kubeconfig.sh
```
3. Execute passando os configs como parâmetros:
```bash
./merge-kubeconfig.sh ~/.kube/config ~/.kube/config.bak ~/.kube/config.bak.20241221_123456
```
4. Dicas importantes:
- Sempre faça backup do seu kubeconfig atual antes de fazer merge
- Verifique se os contextos não têm nomes conflitantes
- Após o merge, teste o acesso a cada cluster:
```bash
kubectl config get-contexts
kubectl config use-context NOME_DO_CONTEXTO
kubectl get nodes

```
5. Caminhos importantes:
- Arquivo de configuração padrão: ~/.kube/config
- Script de merge sugerido: ~/merge-kubeconfig.sh
Este método garante um merge seguro dos seus kubeconfigs, mantendo backups e verificando a existência dos arquivos antes de realizar a operação.
