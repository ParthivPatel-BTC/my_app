module RegexpConstants
  VALID_FAX_REGEXP = /\A[0-9()]+[^a-zA-Z]+/
  VALID_EMAIL_REGEXP = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
end
