#logging 


## client

for concepts see http://engineering.talis.com/articles/client-side-error-logging/

### Libraries
````
<script src="/static/lib/angular-logging.js"></script>
<script src="/static/lib/AngularLogExtender/0.0.7/log-ex-unobtrusive.min.js"></script>
````
#### 'ngLogging'
source=static/lib/angular-logging.js
decorates $log

#### 'log.ex.uo'

.config([ 'logExProvider', function(logExProvider) {
            logExProvider.enableLogging(true);
        } ])
 
 app.js:run
   Logging.enabled = true;
          
 services.js errorLogService
 
 ### Error trap
       
## server

