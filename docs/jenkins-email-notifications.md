# Jenkins email notifications

Both xpact Jenkinsfiles provide an `EMAIL_RECIPIENTS` string parameter.
After Jenkins first loads the updated Jenkinsfile, open the xpact job's
**Build with Parameters** page and enter comma-separated addresses, for example
`first@example.com,second@example.com`.

The initial default is empty, which disables notifications. A submitted value
becomes the default for subsequent builds of that job. Clear the field and run
a build to disable notifications again. Surrounding whitespace is removed.
Addresses stay in the Jenkins job's parameters rather than the repository.

Each build sends one email when its final result is `FAILURE` or `UNSTABLE`,
including yellow builds caused by failing tests. Successful, aborted, and
not-built results do not send email. The message includes the result, build
number, build page, and console link.

The notification runs in the pipeline's final `post cleanup` block, after
artifact and test publication. It needs no agent workspace. A mail delivery
error is logged while preserving the original build result; cancellation is
allowed to interrupt sending.

Configure the SMTP server under **Manage Jenkins > System > E-mail
Notification** before relying on delivery. These pipelines use the standard
[`mail` step](https://www.jenkins.io/doc/pipeline/steps/workflow-basic-steps/#mail-mail).
The system administrator email address supplies the default sender and reply
address; it is separate from `EMAIL_RECIPIENTS`.

## Verification without sending email

`tests/jenkins/test_email_notifications.groovy` loads both complete Jenkinsfiles
with stubbed Pipeline steps and a stubbed mail sender. Run it with a Groovy
runtime from the repository root:

```sh
groovy tests/jenkins/test_email_notifications.groovy
```

It verifies result filtering, empty and retained recipient values, one send per
build, publication ordering, mail failures, and interruption propagation.
The test does not contact Jenkins or an SMTP server.
