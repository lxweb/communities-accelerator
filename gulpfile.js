const { watch, series, parallel, src, dest } = require('gulp');
const fileSync = require('gulp-file-sync');
const cssmin = require('gulp-cssmin');
const less = require('gulp-less');

function defaultTask(cb) {
  // watch('./force-app/main/default/lwc/**', syncLWCToSRC);
  //series(watchLess);
  watch('./src/lwc/**/*.less', lessc);
  cb();
}

function syncLWCToSRC(cb){
  fileSync( './force-app/main/default/lwc', 
    './src/lwc', { 
      recursive: true, 
      ignore: ['.eslintrc.json', 'jsconfig.json'] 
    })
  return cb(); 
}

function lessc(cb){
  console.log("lessc");
  src('./src/lwc/**/*.less')  // only compile the entry file
      .pipe(less())
      .pipe(dest('./src/lwc/'))
  cb();
}

function watchLess(cb){
  console.log("watchLess");
  watch('./src/lwc/**/*.less', lessc);  // Watch all the .less files into styles, then run the less task
  cb()
}

//watch('./src/lwc/**/*.less', lessc);
// watch('./force-app/main/default/lwc/**', syncLWCToSRC);

exports.default = series(defaultTask);
exports.dev = series(watchLess);
exports.lessc = series(lessc);
exports.watchLess = series(watchLess);

