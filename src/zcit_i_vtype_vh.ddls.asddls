@EndUserText.label: 'Vendor Type Dropdown'
@ObjectModel.resultSet.sizeCategory: #XS
@Metadata.ignorePropagatedAnnotations: true
define view entity ZCIT_I_VTYPE_VH 
  as select from I_Language 
{
      @UI.textArrangement: #TEXT_ONLY
  key cast('Hardware' as abap.char(20)) as VendorType
}
union select from I_Language 
{
  key cast('Software' as abap.char(20)) as VendorType
}
union select from I_Language 
{
  key cast('Services' as abap.char(20)) as VendorType
}
union select from I_Language 
{
  key cast('Logistics' as abap.char(20)) as VendorType
}
