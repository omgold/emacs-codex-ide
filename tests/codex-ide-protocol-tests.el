;;; codex-ide-protocol-tests.el --- Protocol tests -*- lexical-binding: t; -*-

(require 'ert)
(require 'codex-ide)

(ert-deftest codex-ide-network-access-policy-covers-restricted-sandboxes ()
  (dolist (codex-ide-sandbox-mode '("read-only" "workspace-write"))
    (dolist (codex-ide-network-access '("off" "on"))
      (let* ((policy (codex-ide--turn-start-sandbox-policy))
             (encoded (json-encode policy))
             (enabled (equal codex-ide-network-access "on")))
        (should (equal (alist-get 'type policy)
                       (if (equal codex-ide-sandbox-mode "read-only")
                           "readOnly" "workspaceWrite")))
        (should (eq (alist-get 'networkAccess policy)
                    (if enabled t :json-false)))
        (should (string-match-p (if enabled
                                    "\"networkAccess\":true"
                                  "\"networkAccess\":false")
                                encoded))
        (when (equal codex-ide-sandbox-mode "workspace-write")
          (should (equal (alist-get 'writableRoots policy)
                         (vector (codex-ide--get-working-directory)))))))))

(ert-deftest codex-ide-network-access-does-not-restrict-full-access ()
  (let ((codex-ide-sandbox-mode "danger-full-access"))
    (dolist (codex-ide-network-access '("off" "on"))
      (should (equal (codex-ide--turn-start-sandbox-policy)
                     '((type . "dangerFullAccess")))))))

(provide 'codex-ide-protocol-tests)
;;; codex-ide-protocol-tests.el ends here
