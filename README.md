# nhsonline-fido-client-ios

> NHS Online FIDO client for IOS

## Get code
Clone from the GitLab repo: https://git.nhschoices.net/nhsonline/nhsonline-fido-client-ios.git

```bash
git clone https://git.nhschoices.net/nhsonline/nhsonline-fido-client-ios.git 
```

## Cocoapods

To update the cocoapod a number of steps need to be taken

1. Make sure you have cocoapods on your machine:
        sudo gem install cocoapods
2.  Make the changes to the source code
3.  Check the current tag version in gitlab
4.  Update the podspec file with the next incremental spec.version based on the tag
5.  Push the podspec:
        pod repo push FidoClientIOS FidoClientIOS.podspec
6. Check in the nhsonline-fide-client-ios-cocopod git repo that the correct cocoapod has been created under the FidoClientIOS folder
