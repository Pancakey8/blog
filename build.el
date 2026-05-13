(require 'package)
(package-initialize)
(require 'ox-publish)
(require 'htmlize)

(setq org-html-htmlize-output-type 'css)
(setq org-html-htmlize-font-prefix "org-src-")


(setq org-publish-project-alist
      '(("blog-posts"
	 :base-directory "./posts/"
	 :base-extension "org"
	 :exclude "\\(^\\|/\\)\\..*\\.org$"
	 :publishing-directory "./dist/posts"
	 :recursive t
	 :publishing-function org-html-publish-to-html)

	("blog-posts-resources"
	 :base-directory "./posts/"
	 :base-extension "css"
	 :publishing-directory "./dist/posts"
	 :recursive t
	 :publishing-function org-publish-attachment)))

(org-publish-all t)
