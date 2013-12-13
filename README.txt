Workflow:

1. Android on application start registers his device on google cloud - receives registration id.
2. Android registers pair device_id:user_id in service

3. Lync plugin requests service for device id based on user id
4. Lync publishes messages via REST interface??? (still need to check how to do this properly)