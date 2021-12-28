FROM jekyll/jekyll
WORKDIR /srv/jekyll
CMD jekyll serve --unpublished --incremental --force_polling

# docker run -v "C:\Users\tugen\Documents\GitHub\tugend.github.io:/srv/jekyll" -p 4000:4000 compile-jekyll
# docker commit <name-of-container> compile-jekyll-cached
# docker run -v "C:\Users\tugen\Documents\GitHub\tugend.github.io:/srv/jekyll" -p 4000:4000 compile-jekyll-cached

# NOTE: 
# Posts that are dated in the future are not visible by default?
# To build a new post locally, you may have to go into the container and run rm -rf _site for a clean un-cached build
# Links does not work locally, you have to manually replace http://0.0.0.0 with http://localhost instead.