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
apt-get update
")

(defmethod read-file (path (type (eql :index)) &key))

(defmethod read-file (path (type (eql :installed)) &key)
  (let ((folder (first path)))
    (when (package-exists folder)
      (read-file (rest path) :package-info :package folder))))

(defmethod read-file (path (type (eql :package-info)) &key package)
  (let ((file (first path)))
    (cond ((string= file "name") (read-file nil :package-name :package package))
          ((string= file "version") (read-file nil :package-version :package package))
          ((string= file "desc") (read-file nil :package-desc :package package)))))

(defmethod read-file (path (type (eql :package-name)) &key package)
  (format nil "~A~%" package))

(defmethod read-file (path (type (eql :package-version)) &key package)
  (format nil "~A~%" (package-version package)))

(defmethod read-file (path (type (eql :package-desc)) &key package)
  (format nil "~A~%" (package-desc package)))
