;;; sunshine.el --- Provide weather and forecast information.
;;; Commentary:
;;
;; Use OpenWeatherMap's API to provide current weather and forecast information within Emacs!
;;
;;; Code:
(require 'cl-macs)
(require 'url)
(require 'url-cache)
(require 'time-date)
(require 'json)

;;; Declaring this is polite, though this var is created later by url-http.
(defvar url-http-end-of-headers)

(defun sunshine-extract-response (buf)
  "Extract the JSON response from the buffer returned by url-http.
Provide the buffer as BUF."
  (with-current-buffer buf
    (goto-char url-http-end-of-headers)
    (prog1 (json-read)
      (kill-buffer))))

(defun sunshine-get-forecast (query &optional units)
  "Get forecast data from OpenWeatherMap's API.
Provide a location as QUERY and optionally the preferred unit
of measurement as UNITS (e.g. 'metric' or 'imperial')."
  (let* ((url (concat "http://api.openweathermap.org/data/2.5/forecast/daily?q="
                      query
                      "&mode=json&units=imperial&cnt=5"))
         (weather-json-buffer (url-retrieve-synchronously url)))
    (sunshine-build-simple-forecast
     (sunshine-extract-response weather-json-buffer))))

(defun sunshine-build-simple-forecast (fc-data)
  "Build a simple, legible forecast from FC-DATA.
FC-DATA is the raw forecast data resulting from calling json-read on the
forecast results."
  (cl-loop for day across (cdr (assoc 'list fc-data)) collect
           (list
            (cons 'date (format-time-string "%A %h %e" (seconds-to-time (cdr (assoc 'dt day)))))
            (cons 'desc (cdr (assoc 'main (elt (cdr (assoc 'weather day)) 0))))
            (cons 'temp (cdr (assoc 'temp day)))
            (cons 'pressure (cdr (assoc 'pressure day))))
           ))

(defun sunshine-open-forecast-window ()
  "Display the forecast."
  (let ((buf (get-buffer-create "*Forecast*")))
    (pop-to-buffer buf)
    (erase-buffer)))

(defun sunshine-forecast ()
  "The main entry into Sunshine; display the forecast in a window."
  (interactive)
  (sunshine-open-forecast-window)
  (sunshine-draw-forecast
    (sunshine-get-forecast "Brookline,MA")))

(defun sunshine-draw-forecast (forecast)
  "Draw FORECAST in pretty ASCII."
  (let ((hline (concat "+"
                       (mapconcat 'identity
                                  (cl-loop for i from 1 to 5 collect
                                           (concat (make-string 18 ?-)
                                                   "+")) "")
                       "\n")))

    (insert (concat hline "| "))
    (while forecast
      (let* ((day (car forecast))
             (date (cdr (assoc 'date day))))
        (insert date)
        (if (< (length date) 16)
            (insert (make-string (- 16 (length date)) ? )))
        (insert " | "))
      (setq forecast (cdr forecast)))
    (insert (concat "\n" hline))))

(provide 'sunshine)
;;; sunshine.el ends here