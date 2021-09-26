FROM jekyll/jekyll

WORKDIR /srv/jekyll
CMD jekyll serve --unpublished --incremental --force_polling

# docker run -v "C:\Users\tugen\Documents\GitHub\tugend.github.io:/srv/jekyll" -p 4000:4000 compile-jekyll
# docker commit <name-of-container> compile-jekyll-cached
# docker run -v "C:\Users\tugen\Documents\GitHub\tugend.github.io:/srv/jekyll" -p 4000:4000 compile-jekyll-cached