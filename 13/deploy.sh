ENV=$1
VERSION=$2
DEPLOYMENT_DIR="/tmp/deployments/$ENV"
ARCHIVE="deploy_${VERSION}.tar.gz"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "=========Validaton========="

if [[ -z "$ENV" || -z "$VERSION" ]];then
	echo "Usage: ./deploy.sh <staging|production> <version>"
	exit 1
fi

if [[ "$ENV" != "staging" && "$ENV" != "production" ]];then
	echo "Invalid Environment"
	exit 1
fi

echo "=========Git uncommited changes stashed======"

if ! git diff --quiet || ! git diff --cached --quiet; then
	git stash
	echo "Uncommited changes stashed"
fi

echo "=========Git checkout version========"

git checkout "$VERSION"

if [ $? -ne 0 ];then
	echo "Invalid version tag $VERSION"
	exit 1
fi

echo "=========Deployement archive========="

tar -czf "$ARCHIVE" \
	--exclude='.git' \
	--exclude='node_modules' \
	.

echo "$TIMESTAMP archive created $ARCHIVE"

echo "=========Deployement================="

mkdir -p "$DEPLOYMENT_DIR"
cp "$ARCHIVE" "$DEPLOYMENT_DIR"
cd "$DEPLOYMENT_DIR" || exit 1
tar -xzf "$ARCHIVE"
echo "$TIMESTAMP files moved to $DEPLOYMENT_DIR"

echo "==========Final validation==========="

if [ -f "$DEPLOYMENT_DIR/index.html" ] && ls "$DEPLOYMENT_DIR"/*.css >/dev/null 2>&1; then
    echo "$TIMESTAMP - DEPLOY SUCCESS"
    exit 0
else
    echo "$TIMESTAMP - DEPLOY FAILED"
    exit 1
fi


