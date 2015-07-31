(in-package :dpkg-fs)

(defgeneric read-file (path type &key)
  (:documentation "Reads a single file."))

(defmethod read-file (path (type (eql :root)) &key)
  (let ((file (first path)))
    (cond ((string= file "installed") (read-file (rest path) :installed))
          ((string= file "index") (read-file (rest path) :index))
          ((string= file "sync") (read-file (rest path) :sync)))))

(defmethod read-file (path (type (eql :sync)) &key)
  "#!/bin/bash
sudo apt-get update
")

(defmethod read-file (path (type (eql :index)) &key)
  (let ((folder (first path)))
    (when (package-available folder)
      (read-file (rest path) :package-index-info :package folder))))

(defmethod read-file (path (type (eql :package-index-info)) &key package)
  (let ((file (first path)))
    (cond ((string= file "name") (read-file nil :package-name :package package))
          ((string= file "version") (read-file nil :package-index-version :package package))
          ((string= file "desc") (read-file nil :package-index-desc :package package))
          ((string= file "install") (read-file nil :package-install :package package)))))

(defmethod read-file (path (type (eql :package-install)) &key package)
  (format nil "#!/bin/bash
sudo apt-get install ~A
" package))

(defmethod read-file (path (type (eql :package-index-version)) &key package)
  (format nil "~A~%" (package-index-version package)))

(defmethod read-file (path (type (eql :package-index-desc)) &key package)
  (format nil "~A~%" (package-index-desc package)))

(defmethod read-file (path (type (eql :installed)) &key)
  (let ((folder (first path)))
    (when (package-exists folder)
      (read-file (rest path) :package-info :package folder))))

(defmethod read-file (path (type (eql :package-info)) &key package)
  (let ((file (first path)))
    (cond ((string= file "name") (read-file nil :package-name :package package))
          ((string= file "version") (read-file nil :package-version :package package))
          ((string= file "desc") (read-file nil :package-desc :package package))
          ((string= file "uninstall") (read-file nil :package-uninstall :package package)))))

(defmethod read-file (path (type (eql :package-info)) &key package)
  (format nil "#!/bin/bash
sudo apt-get remove ~A
" package))

(defmethod read-file (path (type (eql :package-name)) &key package)
  (format nil "~A~%" package))

(defmethod read-file (path (type (eql :package-version)) &key package)
  (format nil "~A~%" (package-version package)))

(defmethod read-file (path (type (eql :package-desc)) &key package)
  (format nil "~A~%" (package-desc package)))
