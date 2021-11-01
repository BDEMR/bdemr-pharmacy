const fs = require('fs-extra');
const shell = require('shelljs');

const publish = (version) => {
  let res = shell.exec(`gcloud app deploy --version ${version} --quiet --project bdemr-deploy`);
  if (res.code !== 0) {
    shell.echo('Error: gcloud app deploy --quiet --project bdemr-deploy');
    shell.exit(1);
  }
}

const gulpBuild = () => {
  let res = shell.exec('gulp build');
  if (res.code !== 0) {
    shell.echo('Error: gulp build failed');
    shell.exit(1);
  }
}

const moveContent = () => {
  try {
    fs.removeSync('./gcp-production/app');
  } catch (err) {
    'pass'
  }
  fs.renameSync('./build-debug', './gcp-production/app');
}

const getVersion = () => {
  let config = fs.readFileSync('src/assets/config-production.coffee', 'utf8')
  let searchString = "clientVersion: '"
  let index = config.indexOf(searchString)
  let index2 = config.indexOf("'", (index + searchString.length + 1))
  let first = config.slice(0, (index + searchString.length))
  let version = config.slice((index + searchString.length), index2)
  return version.replace('.', '-').replace('.', '-')
}

gulpBuild()
moveContent()
let version = getVersion()
process.chdir('./gcp-production')
publish(version);
console.log("Build Finished.")