(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless (package-installed-p 'htmlize)
  (package-refresh-contents)
  (package-install 'htmlize)
  (package-install 'idris-mode))
(require 'ox-publish)
(require 'htmlize)

(setq org-html-htmlize-output-type 'css)
(setq org-html-htmlize-font-prefix "org-src-")

(defun my/get-org-file-metadata (file)
  "Extract title and date from an org file."
  (with-temp-buffer
    (insert-file-contents file)
    (let ((title (or (cadar (org-collect-keywords '("TITLE"))) "Untitled"))
          (date (or (cadar (org-collect-keywords '("DATE"))) ""))
	  (desc (or (cadar (org-collect-keywords '("DESCRIPTION"))) ""))
          (filename (file-name-base file)))
      (list title date filename desc))))

(defun my/generate-homepage ()
  "Create HTML list items from org files and inject into index.html."
  (let* ((posts-dir "./posts/")
         (template-file "./pages/.post-item.html")
         (index-template "./pages/.index-template.html")
         (dist-dir "./dist/")
         (output-index (concat dist-dir "index.html"))
         (post-files (directory-files posts-dir t "^[^\\.].*\\.org$"))
         (items-html ""))

    ;; 1. Ensure the dist directory exists so we don't get a 'path not found' error
    (make-directory dist-dir t)
    
    ;; 2. Build the list of HTML items by reading metadata from each .org file
    (dolist (file post-files)
      (let* ((meta (my/get-org-file-metadata file))
             (item (with-temp-buffer 
                     (insert-file-contents template-file)
                     (goto-char (point-min))
                     ;; Replace our placeholders with actual data
                     (while (search-forward "{{{title}}}" nil t) (replace-match (nth 0 meta) t t))
                     (goto-char (point-min))
                     (while (search-forward "{{{date}}}" nil t) (replace-match (nth 1 meta) t t))
                     (goto-char (point-min))
                     (while (search-forward "{{{desc}}}" nil t) (replace-match (nth 3 meta) t t))
                     (goto-char (point-min))
                     (while (search-forward "{{{filename}}}" nil t) (replace-match (nth 2 meta) t t))
                     (buffer-string))))
        (setq items-html (concat items-html item))))

    ;; 3. Read the main template, swap the {{{posts}}} tag, and write to dist/index.html
    (with-temp-file output-index
      (insert-file-contents index-template)
      (goto-char (point-min))
      (while (search-forward "{{{posts}}}" nil t)
        (replace-match items-html t t))
      ;; The file is automatically saved to output-index when this block ends
      (message "Successfully generated %s" output-index))))

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
	 :publishing-function org-publish-attachment)

	("pages"
	 :base-directory "./pages/"
	 :base-extension "css\\|html"
	 :publishing-directory "./dist"
	 :recursive t
	 :publishing-function org-publish-attachment)))

(my/generate-homepage)
(org-publish-all t)
