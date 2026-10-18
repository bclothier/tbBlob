# gen_probe report

- modules: 65
- records: 85
- opaque aliases: 60
- delegates (incl. synthesized): 67
- functions: 848

## Renames
- type git_cert_x509: collides with ('enumvalue', 'GIT_CERT_X509') -> git_cert_x509_
- type git_credential_userpass_plaintext: collides with ('enumvalue', 'GIT_CREDENTIAL_USERPASS_PLAINTEXT') -> git_credential_userpass_plaintext_
- type git_credential_username: collides with ('enumvalue', 'GIT_CREDENTIAL_USERNAME') -> git_credential_username_
- type git_credential_ssh_key: collides with ('enumvalue', 'GIT_CREDENTIAL_SSH_KEY') -> git_credential_ssh_key_
- type git_credential_ssh_interactive: collides with ('enumvalue', 'GIT_CREDENTIAL_SSH_INTERACTIVE') -> git_credential_ssh_interactive_
- type git_credential_ssh_custom: collides with ('enumvalue', 'GIT_CREDENTIAL_SSH_CUSTOM') -> git_credential_ssh_custom_
- type git_error: collides with ('enumvalue', 'GIT_ERROR') -> git_error_
- function git_repository_open_bare: collides with ('enumvalue', 'GIT_REPOSITORY_OPEN_BARE') -> git_repository_open_bare_ Alias "git_repository_open_bare"

## Notes
- opaque typedef LIBSSH2_SESSION -> struct _LIBSSH2_SESSION: alias emitted under the typedef name
- opaque typedef LIBSSH2_USERAUTH_KBDINT_PROMPT -> struct _LIBSSH2_USERAUTH_KBDINT_PROMPT: alias emitted under the typedef name
- opaque typedef LIBSSH2_USERAUTH_KBDINT_RESPONSE -> struct _LIBSSH2_USERAUTH_KBDINT_RESPONSE: alias emitted under the typedef name
- opaque typedef git_note_iterator -> struct git_iterator: alias emitted under the typedef name
- bitfield git_commit_create_options.allow_empty_commit: emitted as storage field bits_allow_empty_commit
