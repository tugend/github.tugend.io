@REM RUBY, Ruby's package manager bundle and jekyll are a pain to install
@REM Try using docker instead! 
@REM docker run --volume="%cd%\tugend.github.io:/srv/jekyll"  --publish 4000:4000  jekyll/jekyll jekyll serve --unpublished
@REM Docker restart <container-name>

@REM docker run --volume="C:\Users\tugen\Documents\GitHub\tugend.github.io:/srv/jekyll"  --publish 4000:4000 --publish 80:80 --publish 35729:35729 jekyll/jekyll jekyll serve --unpublished --livereload --incremental --watch --force_polling -H 0.0.0.0 -P 4000
@REM docker run --volume="C:\Users\tugen\Documents\GitHub\tugend.github.io:/srv/jekyll" --publish 35729:35729 --publish 4000:4000 jekyll/jekyll jekyll serve --unpublished --livereload --incremental --force_polling -H 0.0.0.0 

bundle exec jekyll serve --unpublished