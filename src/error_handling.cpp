#include "error_handling.h"

#include <typeinfo>
#include <string>

extern "C" {
    #include "postgres.h"
}

void report_out_of_memory() {
    ereport(ERROR,
        (errcode(ERRCODE_OUT_OF_MEMORY),
         errmsg("Out of memory")));
}

/*
 * Reports a generic C++ exception as a PostgreSQL error
 *
 * May produce specialized SQLSTATE values and/or messages
 * depending on the type of the exception
 */
void report_exception(const std::exception& exception) {
    const std::bad_alloc* bad_alloc = dynamic_cast<const std::bad_alloc*>(&exception);
    if(bad_alloc != nullptr) {
        report_out_of_memory();
        return;
    }

    // If we don't have a special way to handle this exception, report
    // a generic error.
    ereport(ERROR, (
        errcode(ERRCODE_EXTERNAL_ROUTINE_EXCEPTION),
        errmsg("C++ exception: %s", typeid(exception).name()),
        errdetail("%s", exception.what())
    ));
}
