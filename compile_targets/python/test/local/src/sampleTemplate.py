#!/usr/bin/env python

# Add Path to sys path
## warning: its necessary install the package : pip install "name of package"
### call the package generated locally
#import pytemplate.SampleContract_pb2 as SampleContract


import pytemplate.SampleContract_pb2 as SampleContract
from google.protobuf.json_format import MessageToJson

# Request Object
templateObject = SampleContract.TemplateContract()
templateObject.userName = "john_doe"
templateObject.emailId = "johndoe@work.com"
templateObject.age = 32
templateObject.department = "IT"
templateObject.country = "INdia"
 
# Print Request Created Object
print (MessageToJson(templateObject))
 