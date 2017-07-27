/* Copyright (C) 2017 ETH Zurich, University of Bologna
 * All rights reserved.
 *
 * This code is under development and not yet released to the public.
 * Until it is released, the code is under the copyright of ETH Zurich and
 * the University of Bologna, and may contain confidential and/or unpublished
 * work. Any reuse/redistribution is strictly forbidden without written
 * permission from ETH Zurich.
 *
 * Bug fixes and contributions will eventually be released under the
 * SolderPad open hardware license in the context of the PULP platform
 * (http://www.pulp-platform.org), under the copyright of ETH Zurich and the
 * University of Bologna.
 */

module spi_master_clkgen
(
    input  logic                        clk,
    input  logic                        rstn,
    input  logic                        en,
    input  logic          [7:0]         clk_div,
    input  logic                        clk_div_valid,
    output logic                        spi_clk,
    output logic                        spi_fall,
    output logic                        spi_rise
);

    logic [7:0] counter_trgt;
    logic [7:0] counter_trgt_next;
    logic [7:0] counter;
    logic [7:0] counter_next;

    logic       spi_clk_next;
    logic       running;

    always_comb
    begin
            spi_rise = 1'b0;
            spi_fall = 1'b0;
            if (clk_div_valid)
                counter_trgt_next = clk_div;
            else
                counter_trgt_next = counter_trgt;

            if (counter == counter_trgt)
            begin
                counter_next = 0;
                spi_clk_next = ~spi_clk;
                if(spi_clk == 1'b0)
                    spi_rise = running;
                else
                    spi_fall = running;
            end
            else
            begin
                counter_next = counter + 1;
                spi_clk_next = spi_clk;
            end
    end

    always_ff @(posedge clk, negedge rstn)
    begin
        if (rstn == 1'b0)
        begin
            counter_trgt <= 'h0;
            counter      <= 'h0;
            spi_clk      <= 1'b0;
            running      <= 1'b0;
        end
        else
        begin
            counter_trgt <= counter_trgt_next;
            if ( !((spi_clk==1'b0)&&(~en)) )
            begin
                running <= 1'b1;
                spi_clk <= spi_clk_next;
                counter <= counter_next;
            end
            else
                running <= 1'b0;
        end
    end



endmodule
