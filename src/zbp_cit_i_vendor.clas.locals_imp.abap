" ==============================================================================
" 1. THE BUFFER: Temporarily holds data until Fiori says "Save"
" ==============================================================================
CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA: mt_insert TYPE TABLE OF zcit_vendor,
                mt_update TYPE TABLE OF zcit_vendor,
                mt_delete TYPE TABLE OF zcit_vendor.
ENDCLASS.

" ==============================================================================
" 2. THE HANDLER: Processes user input and puts it in the buffer
" ==============================================================================
CLASS lhc_Vendor DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Vendor RESULT result.
    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Vendor.
    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Vendor.
    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Vendor.
    METHODS read FOR READ
      IMPORTING keys FOR READ Vendor RESULT result.
    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Vendor.

    " Custom Actions
    METHODS approveVendor FOR MODIFY
      IMPORTING keys FOR ACTION Vendor~approveVendor RESULT result.
    METHODS blockVendor FOR MODIFY
      IMPORTING keys FOR ACTION Vendor~blockVendor RESULT result.
ENDCLASS.

CLASS lhc_Vendor IMPLEMENTATION.
  METHOD get_instance_authorizations. ENDMETHOD.

  METHOD create.
    " AUTOMATION 1: Get the current Timestamp
    GET TIME STAMP FIELD DATA(lv_now).

    " AUTOMATION 2: Find the highest Vendor ID currently in the database
    SELECT MAX( vendor_id ) FROM zcit_vendor INTO @DATA(lv_max_id).

    LOOP AT entities INTO DATA(ls_entity).
      " AUTOMATION 3: Add +1 to generate the next Vendor ID safely!
      lv_max_id = lv_max_id + 1.

      " Set a default status if the user left it blank
      DATA(lv_status) = ls_entity-Status.
      IF lv_status IS INITIAL.
        lv_status = 'Pending Approval'.
      ENDIF.

      APPEND VALUE #(
        vendor_id          = CONV #( lv_max_id )  " Our Auto-Generated ID!
        company_name       = ls_entity-CompanyName
        email_address      = ls_entity-EmailAddress
        phone_number       = ls_entity-PhoneNumber
        website            = ls_entity-Website
        country            = ls_entity-Country
        city               = ls_entity-City
        vendor_type        = ls_entity-VendorType
        status             = lv_status
        performance_rating = ls_entity-PerformanceRating
        created_at         = lv_now
      ) TO lcl_buffer=>mt_insert.

      " Map the generated ID back to the framework so the UI knows it
      INSERT VALUE #( %cid = ls_entity-%cid  VendorId = CONV #( lv_max_id ) ) INTO TABLE mapped-vendor.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    LOOP AT entities INTO DATA(ls_entity).
      " 1. PROTECT DATA: Read the existing record first!
      SELECT SINGLE * FROM zcit_vendor
        WHERE vendor_id = @ls_entity-VendorId
        INTO @DATA(ls_db).

      " 2. ONLY overwrite the exact fields the user actually touched on the screen!
      IF ls_entity-%control-CompanyName = if_abap_behv=>mk-on.
        ls_db-company_name = ls_entity-CompanyName.
      ENDIF.

      IF ls_entity-%control-EmailAddress = if_abap_behv=>mk-on.
        ls_db-email_address = ls_entity-EmailAddress.
      ENDIF.

      IF ls_entity-%control-PhoneNumber = if_abap_behv=>mk-on.
        ls_db-phone_number = ls_entity-PhoneNumber.
      ENDIF.

      IF ls_entity-%control-Website = if_abap_behv=>mk-on.
        ls_db-website = ls_entity-Website.
      ENDIF.

      IF ls_entity-%control-Country = if_abap_behv=>mk-on.
        ls_db-country = ls_entity-Country.
      ENDIF.

      IF ls_entity-%control-City = if_abap_behv=>mk-on.
        ls_db-city = ls_entity-City.
      ENDIF.

      IF ls_entity-%control-VendorType = if_abap_behv=>mk-on.
        ls_db-vendor_type = ls_entity-VendorType.
      ENDIF.

      IF ls_entity-%control-Status = if_abap_behv=>mk-on.
        ls_db-status = ls_entity-Status.
      ENDIF.

      IF ls_entity-%control-PerformanceRating = if_abap_behv=>mk-on.
        ls_db-performance_rating = ls_entity-PerformanceRating.
      ENDIF.

      " 3. Send the fully protected record to the update buffer
      APPEND ls_db TO lcl_buffer=>mt_update.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( vendor_id = ls_key-VendorId ) TO lcl_buffer=>mt_delete.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    " Fiori needs this to read the database and show it on the screen
    SELECT * FROM zcit_vendor
      FOR ALL ENTRIES IN @keys
      WHERE vendor_id = @keys-VendorId
      INTO TABLE @DATA(lt_vendor).

    result = CORRESPONDING #( lt_vendor MAPPING
      VendorId           = vendor_id
      CompanyName        = company_name
      EmailAddress       = email_address
      PhoneNumber        = phone_number
      Website            = website
      Country            = country
      City               = city
      VendorType         = vendor_type
      Status             = status
      PerformanceRating  = performance_rating
      CreatedAt          = created_at
    ).
  ENDMETHOD.

  METHOD lock. ENDMETHOD.

  METHOD approveVendor.
    LOOP AT keys INTO DATA(ls_key).
      " 1. Read existing record
      SELECT SINGLE * FROM zcit_vendor WHERE vendor_id = @ls_key-VendorId INTO @DATA(ls_db).

      " 2. Change Status
      ls_db-status = 'Active'.

      " 3. Send to update buffer
      APPEND ls_db TO lcl_buffer=>mt_update.

      " 4. Refresh UI (FIXED NESTED VALUE SYNTAX)
      INSERT VALUE #( VendorId = ls_key-VendorId
                      %param   = VALUE #( VendorId = ls_key-VendorId
                                          Status   = 'Active' )
                    ) INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.

  METHOD blockVendor.
    LOOP AT keys INTO DATA(ls_key).
      " 1. Read existing record
      SELECT SINGLE * FROM zcit_vendor WHERE vendor_id = @ls_key-VendorId INTO @DATA(ls_db).

      " 2. Change Status and drop rating
      ls_db-status = 'Blocked'.
      ls_db-performance_rating = 0.

      " 3. Send to update buffer
      APPEND ls_db TO lcl_buffer=>mt_update.

      " 4. Refresh UI (FIXED NESTED VALUE SYNTAX)
      INSERT VALUE #( VendorId = ls_key-VendorId
                      %param   = VALUE #( VendorId          = ls_key-VendorId
                                          Status            = 'Blocked'
                                          PerformanceRating = 0 )
                    ) INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

" ==============================================================================
" 3. THE SAVER: SAP automatically calls this at the end to commit to the DB
" ==============================================================================
CLASS lsc_ZCIT_I_VENDOR DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save REDEFINITION.
    METHODS cleanup REDEFINITION.
ENDCLASS.

CLASS lsc_ZCIT_I_VENDOR IMPLEMENTATION.
  METHOD save.
    IF lcl_buffer=>mt_insert IS NOT INITIAL.
      INSERT zcit_vendor FROM TABLE @lcl_buffer=>mt_insert.
    ENDIF.
    IF lcl_buffer=>mt_update IS NOT INITIAL.
      UPDATE zcit_vendor FROM TABLE @lcl_buffer=>mt_update.
    ENDIF.
    IF lcl_buffer=>mt_delete IS NOT INITIAL.
      DELETE zcit_vendor FROM TABLE @lcl_buffer=>mt_delete.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    CLEAR: lcl_buffer=>mt_insert, lcl_buffer=>mt_update, lcl_buffer=>mt_delete.
  ENDMETHOD.
ENDCLASS.
