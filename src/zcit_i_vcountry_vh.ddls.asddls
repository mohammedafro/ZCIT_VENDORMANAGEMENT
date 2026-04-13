@EndUserText.label: 'Vendor Country Dropdown'
@ObjectModel.resultSet.sizeCategory: #XS
@Metadata.ignorePropagatedAnnotations: true
define view entity ZCIT_I_VCOUNTRY_VH 
  as select from I_Language 
{
      @UI.textArrangement: #TEXT_ONLY
  key cast('IN' as abap.char(2)) as CountryCode,
      cast('India' as abap.char(40)) as CountryName
}
union select from I_Language 
{
  key cast('US' as abap.char(2)) as CountryCode,
      cast('United States' as abap.char(40)) as CountryName
}
union select from I_Language 
{
  key cast('UK' as abap.char(2)) as CountryCode,
      cast('United Kingdom' as abap.char(40)) as CountryName
}
