#include <stdexcept>

extern "C" {
    #include "postgres.h"

    #include "fmgr.h"
    #include "miscadmin.h"
    #include "port.h"
}

#include "Numbertext.hxx"

namespace {
    const char* data_path() {
        char share_path[MAXPGPATH];
        get_share_path(my_exec_path, share_path);
        static char extension_path[MAXPGPATH];
        join_path_components(extension_path, share_path, "extension/");
        return extension_path; // TODO: make a subdirectory or something...
    }

    Numbertext &numbertext_instance() {
        static bool initialized = false;
        static Numbertext instance;
        if (!initialized) {
            instance.set_prefix(data_path());
            initialized = true;
        }
        return instance;
    };

    std::string text_to_string(const text* text) {
        size_t len = VARSIZE(text) - VARHDRSZ;
        return std::string(VARDATA(text), len);
    }

    text* string_to_text(const std::string &str) {
        auto text_data = (text*)palloc(VARHDRSZ + str.size());
        if (text_data == nullptr)
            throw std::bad_alloc();
        SET_VARSIZE(text_data, VARHDRSZ + str.size());
        memcpy(VARDATA(text_data), str.data(), str.size());
        return text_data;
    }
}

extern "C" {
    #ifdef PG_MODULE_MAGIC
        PG_MODULE_MAGIC;
    #endif

    PGDLLEXPORT PG_FUNCTION_INFO_V1(numbertext);

    PGDLLEXPORT Datum
    numbertext(PG_FUNCTION_ARGS) {
        try {
            const text *number_text = PG_GETARG_TEXT_P(0);
            const text *language_text = PG_GETARG_TEXT_P(1);
            // TODO: make sure we're dealing with Unicode.
            std::string number_str = text_to_string(number_text);
            std::string language_str = text_to_string(language_text);
            if (numbertext_instance().numbertext(number_str, language_str))
                PG_RETURN_TEXT_P(string_to_text(number_str));
            else
                //PG_RETURN_NULL(); // TODO: report error.
                PG_RETURN_TEXT_P(string_to_text("failed"));
        } catch (std::exception& e) {
            // TODO: exception handling
            //reportException(e);
            PG_RETURN_NULL();
        }
    }
}