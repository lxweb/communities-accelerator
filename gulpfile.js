const { watch, series, parallel, src, dest } = require('gulp');
const dirSync = require( 'gulp-directory-sync' );
const fileSync = require('gulp-file-sync');

function defaultTask(cb) {
  cb();
}

function syncLWCToSRC(cb){
  console.log("syncLWCToSRC");
  fileSync( './force-app/main/default/lwc', 
    './src/lwc', { 
      recursive: true, 
      ignore: ['.eslintrc.json', 'jsconfig.json'] 
    })
  return cb(); 
}

watch('./force-app/main/default/lwc/**', syncLWCToSRC);

exports.default = defaultTask;
exports.dev = series(syncLWCToSRC);
