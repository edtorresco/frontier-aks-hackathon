#!/usr/bin/env bash
set -euo pipefail

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║        Frontier AKS Hackathon — Dev Container            ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Install kubelogin (not yet in a stable Dev Container feature)
echo "► Installing kubelogin..."
KUBELOGIN_VERSION=$(curl -s https://api.github.com/repos/Azure/kubelogin/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4)
curl -sL "https://github.com/Azure/kubelogin/releases/download/${KUBELOGIN_VERSION}/kubelogin-linux-amd64.zip" \
    -o /tmp/kubelogin.zip
unzip -q /tmp/kubelogin.zip -d /tmp/kubelogin
sudo mv /tmp/kubelogin/bin/linux_amd64/kubelogin /usr/local/bin/kubelogin
sudo chmod +x /usr/local/bin/kubelogin
rm -rf /tmp/kubelogin*

echo ""
echo "✔ Tool versions:"
echo "  az          $(az --version 2>&1 | head -1)"
echo "  kubectl     $(kubectl version --client --short 2>/dev/null || kubectl version --client 2>&1 | head -1)"
echo "  kubelogin   $(kubelogin --version 2>&1 | head -1)"
echo "  helm        $(helm version --short)"
echo "  flux        $(flux --version)"
echo "  gh          $(gh --version | head -1)"
echo ""
echo "► Registering required Azure resource providers (runs in background)..."
cat << 'EOF' > /tmp/register-providers.sh
#!/usr/bin/env bash
for ns in \
    Microsoft.ContainerService \
    Microsoft.Monitor \
    Microsoft.Dashboard \
    Microsoft.KubernetesConfiguration \
    Microsoft.AlertsManagement \
    Microsoft.OperationsManagement \
    Microsoft.OperationalInsights; do
    az provider register --namespace "$ns" --only-show-errors 2>/dev/null || true
done
echo "✔ Provider registration complete"
EOF
chmod +x /tmp/register-providers.sh

echo ""
echo "✔ Dev container ready. Run 'az login' to get started."
echo ""
