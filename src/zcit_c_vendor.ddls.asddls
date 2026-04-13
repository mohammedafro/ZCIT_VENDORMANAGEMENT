@EndUserText.label: 'Projection View for Vendor Management'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions: true

define root view entity ZCIT_C_VENDOR 
  provider contract transactional_query
  as projection on ZCIT_I_VENDOR
{
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Vendor ID'
  key VendorId,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @EndUserText.label: 'Company Name'
      CompanyName,

      @EndUserText.label: 'Email Address'
      EmailAddress,
      
      @EndUserText.label: 'Phone Number'
      PhoneNumber,
      
      @EndUserText.label: 'Website'
      Website,

      /* Linking the Country Drop-Down */
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZCIT_I_VCOUNTRY_VH', element: 'CountryCode' } }]
      @EndUserText.label: 'Country'
      Country,
      
      @EndUserText.label: 'City'
      City,

      /* Linking the Vendor Type Drop-Down */
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZCIT_I_VTYPE_VH', element: 'VendorType' } }]
      @EndUserText.label: 'Vendor Type'
      VendorType,

      /* Linking the Vendor Status Drop-Down */
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZCIT_I_VSTAT_VH', element: 'VendorStatus' } }]
      @EndUserText.label: 'Vendor Status'
      Status,
      
      StatusCriticality,

      @EndUserText.label: 'Performance Rating'
      PerformanceRating,

      /* Admin Fields */
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
