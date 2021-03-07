defmodule Exdot.ERDTest do
  use ExUnit.Case, async: true

  import Exdot.ERD

  test "er_diagram" do
    diag =
      er_diagram do
        entity(
          "Students",
          [
            {"id", [:varchar, :not_null, :pk]},
            {"name", [:varchar, :not_null]},
            {"DOB", [:date_time, :not_null]},
            {"phone", [:varchar]},
            {"address", [:text]},
            {"college_id", [:varchar, :not_null, :fk]}
          ],
          "#d0e0d0"
        )

        entity(
          "Colleges",
          [
            {"id", [:varchar, :not_null, :pk]},
            {"name", [:text, :not_null]},
            {"address", [:text]}
          ],
          "#ececfc"
        )

        relation("Students:id", "Colleges:id", "1..N", "1")
      end

    assert diag == """
           digraph  {
             graph [ rankdir = "LR" labeljust = "jleft" splines = "spline" labelloc = "vtop" ]
             node [ rankdir = "TB" shape = "plaintext" fontname = "Helvetica" ]
             edge [ fontname = "Helvetica" ]
             ranksep = "0"
             Students [ label = <<TABLE BGCOLOR="#d0e0d0" BORDER="0" CELLBORDER="1" CELLPADDING="4" CELLSPACING="0" ><TH ><TD ><B ><FONT POINT-SIZE="16" FACE="Helvetica" >Students</FONT></B></TD></TH>
                   <TR ><TD PORT="id" ALIGN="LEFT" ><U ><FONT >id [varchar, not_null]</FONT></U></TD></TR>
                     <TR ><TD PORT="name" ALIGN="LEFT" ><FONT >name [varchar, not_null]</FONT></TD></TR>
                     <TR ><TD PORT="DOB" ALIGN="LEFT" ><FONT >DOB [date_time, not_null]</FONT></TD></TR>
                     <TR ><TD PORT="phone" ALIGN="LEFT" ><FONT >phone [varchar]</FONT></TD></TR>
                     <TR ><TD PORT="address" ALIGN="LEFT" ><FONT >address [text]</FONT></TD></TR>
                     <TR ><TD PORT="college_id" ALIGN="LEFT" ><I ><U ><FONT >college_id [varchar, not_null]</FONT></U></I></TD></TR></TABLE>> shape = "none" ]
             Colleges [ label = <<TABLE BGCOLOR="#ececfc" BORDER="0" CELLBORDER="1" CELLPADDING="4" CELLSPACING="0" ><TH ><TD ><B ><FONT POINT-SIZE="16" FACE="Helvetica" >Colleges</FONT></B></TD></TH>
                   <TR ><TD PORT="id" ALIGN="LEFT" ><U ><FONT >id [varchar, not_null]</FONT></U></TD></TR>
                     <TR ><TD PORT="name" ALIGN="LEFT" ><FONT >name [text, not_null]</FONT></TD></TR>
                     <TR ><TD PORT="address" ALIGN="LEFT" ><FONT >address [text]</FONT></TD></TR></TABLE>> shape = "none" ]
             Students:id -> Colleges:id [ arrowhead = "none" style = "dashed" color = "Gray50" minlen = "10" headlabel = "   1..N" taillabel = " 1" ]
           }
           """
  end
end
