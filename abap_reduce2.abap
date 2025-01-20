DATA: lt_table   TYPE REF TO data,
      lo_struct  TYPE REF TO cl_abap_structdescr,
      lt_fields  TYPE abap_compdescr_tab,
      lt_totals  TYPE REF TO data.

FIELD-SYMBOLS: <fs_table>    TYPE STANDARD TABLE,
               <fs_line>     TYPE ANY,
               <fs_field>    TYPE ANY,
               <fs_totals>   TYPE ANY,
               <fs_total_field> TYPE ANY.

" Create a dynamic internal table
DATA(lo_table_type) = cl_abap_tabledescr=>create( 
                      p_line_type = cl_abap_structdescr=>create(
                        VALUE #( ( name = 'COL1' type = cl_abap_elemdescr=>get_integer( ) )
                                 ( name = 'COL2' type = cl_abap_elemdescr=>get_integer( ) )
                                 ( name = 'COL3' type = cl_abap_elemdescr=>get_integer( ) ) ) ) ).

CREATE DATA lt_table TYPE HANDLE lo_table_type.
ASSIGN lt_table->* TO <fs_table>.

" Populate the dynamic internal table
APPEND VALUE #( COL1 = 10 COL2 = 20 COL3 = 30 ) TO <fs_table>.
APPEND VALUE #( COL1 = 5  COL2 = 15 COL3 = 25 ) TO <fs_table>.
APPEND VALUE #( COL1 = 7  COL2 = 14 COL3 = 21 ) TO <fs_table>.

" Get the structure description of the dynamic table's line type
lo_struct ?= cl_abap_typedescr=>describe_by_data( <fs_table> ).
lt_fields = lo_struct->components.

" Create a structure to hold column totals
CREATE DATA lt_totals TYPE HANDLE lo_struct.
ASSIGN lt_totals->* TO <fs_totals>.

" Initialize totals structure
LOOP AT lt_fields ASSIGNING FIELD-SYMBOL(<fs_field>).
  ASSIGN COMPONENT <fs_field>-name OF STRUCTURE <fs_totals> TO <fs_total_field>.
  IF sy-subrc = 0.
    <fs_total_field> = 0.
  ENDIF.
ENDLOOP.

" Calculate totals for each column
LOOP AT <fs_table> ASSIGNING <fs_line>.
  LOOP AT lt_fields ASSIGNING FIELD-SYMBOL(<fs_field>).
    ASSIGN COMPONENT <fs_field>-name OF STRUCTURE <fs_line> TO <fs_total_field>.
    IF sy-subrc = 0.
      ASSIGN COMPONENT <fs_field>-name OF STRUCTURE <fs_totals> TO <fs_total_field>.
      IF sy-subrc = 0.
        <fs_total_field> = <fs_total_field> + <fs_field>.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDLOOP.

" Append totals as the last row in the table
APPEND <fs_totals> TO <fs_table>.

" Output the table
LOOP AT <fs_table> ASSIGNING <fs_line>.
  LOOP AT lt_fields ASSIGNING FIELD-SYMBOL(<fs_field>).
    ASSIGN COMPONENT <fs_field>-name OF STRUCTURE <fs_line> TO <fs_total_field>.
    IF sy-subrc = 0.
      WRITE: / <fs_field>-name, ':', <fs_total_field>.
    ENDIF.
  ENDLOOP.
  WRITE: / '---'.
ENDLOOP.