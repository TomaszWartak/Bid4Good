export function reduceErrors(errors) {
    if (!Array.isArray(errors)) {
        errors = [errors];
    }
    let errorsJSON ='';
    return errors
        .filter(error => !!error)
        .map(error => {
            if ( isApplicationError( error )) {
                errorsJSON = applicationErrorToJSON( error );
                return errorsJSON;
            } else if ( isAccessError( error )) {
                errorsJSON = fieldErrorsToJSON( error );
                return errorsJSON;
            }
            else if ( isDMLError( error )) {
                errorsJSON = dmlErrorToJSON( error );
                return errorsJSON;
            }
            return error.message || error.body || error.statusText; 
        })
        .filter(message => !!message);
}

function isApplicationError( error ) {
    return error && 
        error.body && 
        error.body.message;
}

function applicationErrorToJSON( error ) {
    let jsonErrorOutput = 'No application error found';
    if ( isApplicationError( error )) {
        const appError = error.body.message;
        jsonErrorOutput = JSON.stringify({ message: appError }, null, 2);
    }
    return jsonErrorOutput;
}

function isAccessError( error ) {
    return error && 
        error.body && 
        error.body.fieldErrors;
}

function accessErrorToJSON( error ) {
    return this.fieldErrorsToJSON( error )
}

function fieldErrorsToJSON( error ) {
    let jsonErrorOutput = 'No field errors found';

    if ( isAccessError( error )) {
        const fieldErrors = errorObject.body.fieldErrors;
        const processedErrors = Object.keys(fieldErrors)
            .map(field => {
                const errorsForField = fieldErrors[field]; 
                return errorsForField.map(singleError => {
                    return {
                        field: field,
                        message: singleError.message,
                        errorType: singleError.statusCode 
                    };
                });
            })
            .flat(); 
        jsonErrorOutput = JSON.stringify(processedErrors, null, 2);
    }

    return jsonErrorOutput;
}

function isDMLError( error ) {
    return error && 
        error.body && 
        error.body.pageErrors && 
        error.body.pageErrors.length > 0
}

function dmlErrorToJSON( error ) {
    let jsonErrorOutput = 'No DML errors found';    
    if ( isDMLError( error )) {
        const dmlError = error.body.pageErrors[0];
        jsonErrorOutput = JSON.stringify(dmlError, null, 2);
    }
    return jsonErrorOutput;
}
