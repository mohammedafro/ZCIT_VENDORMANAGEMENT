@EndUserText.label: 'Vendor Status Dropdown'
@ObjectModel.resultSet.sizeCategory: #XS
@Metadata.ignorePropagatedAnnotations: true
define view entity ZCIT_I_VSTAT_VH 
  as select from I_Language 
{
      @UI.textArrangement: #TEXT_ONLY
  key cast('Active' as abap.char(20)) as VendorStatus
}
union select from I_Language 
{
  key cast('Pending Approval' as abap.char(20)) as VendorStatus
}
union select from I_Language 
{
  key cast('Blocked' as abap.char(20)) as VendorStatus
}
