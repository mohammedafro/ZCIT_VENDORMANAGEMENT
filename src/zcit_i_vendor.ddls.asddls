@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Vendor Management'

define root view entity ZCIT_I_VENDOR 
  as select from zcit_vendor
{
  key vendor_id             as VendorId,
  
      company_name          as CompanyName,
      email_address         as EmailAddress,
      phone_number          as PhoneNumber,
      website               as Website,
      
      country               as Country,
      city                  as City,
      
      vendor_type           as VendorType,
      
      status                as Status,
      /* PREMIUM UI: Dynamic Status Colors */
      case status
        when 'Active'           then 3  /* 3 = Green  */
        when 'Pending Approval' then 2  /* 2 = Orange */
        when 'Blocked'          then 1  /* 1 = Red    */
        else 0
      end                   as StatusCriticality,
      
      performance_rating    as PerformanceRating,

      /* Standard Admin Fields */
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}
