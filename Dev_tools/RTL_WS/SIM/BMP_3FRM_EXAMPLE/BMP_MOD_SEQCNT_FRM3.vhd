 ------------------------------------------------------------------------------
 -- Title                                                                    --
 --  ビット�?�ッ�? リー�?/ライトパ�?ケージの簡易使用モジュール                --
 --  シーケンシャルコントロール�?                                            --
 ------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.bmp_pkg.all;

entity BMP_MOD_SEQCNT_FRM3 is
	generic
	(
		-- ファイル�?
		BMP_RD_FILE      : string := "read.bmp";
		BMP_WR_FILE_FRM1 : string := "write_frm1.bmp";
		BMP_WR_FILE_FRM2 : string := "write_frm2.bmp";
		BMP_WR_FILE_FRM3 : string := "write_frm3.bmp"
	);
	port
	(
		-- シス�?�?
		CLK			: in	std_logic;
		-- リード�?�
		RE			: in	std_logic;
		RDATA		: out	std_logic_vector(31 downto 0) := (others => '0');
		-- ライト�?�
		WE			: in	std_logic;
		WDATA		: in	std_logic_vector(31 downto 0)
	);
end BMP_MOD_SEQCNT_FRM3;

architecture behavior of BMP_MOD_SEQCNT_FRM3 is
begin

	-------------------------------
	-- リード�?�メモリ
	process
		variable	bmp_data	: BMP_INFO;
		variable	biWidth		: integer;
		variable	biHeight	: integer;
		variable	biBitCount	: integer;
		variable	PIX_DATA	: std_logic_vector(31 downto 0);
		variable	result		: boolean;
	begin
		-- �?初に�?ず呼び出�?
		init_data( bmp_data );

		-- 「READ_BMP_FILE_NAME」を開き「bmp_data」に読み込�?
		open_bmp( BMP_RD_FILE, bmp_data, result );
		if ( result = FALSE ) then
			assert false
			report "open_bmp fail."
			severity failure;
			wait;
		end if;

		-- ビット�?�ップ�?��?報を取得す�?
		get_info( bmp_data, biWidth, biHeight, biBitCount );


		-- ビット�?�ップ�?�左上座�?(0,0)から右�?(biWidth-1,biHeight-1)までルー�?
        for f_loop in 0 to 2 loop
    		for y_loop in 0 to biHeight-1 loop
    			for x_loop in 0 to biWidth-1 loop
    				wait until (RE = '1' and (CLK'event and CLK = '1'));
    
    				-- ?��ピクセルの読み出�?
    				-- ?��ピクセルが３２Ｂ?��ｔに�?たな�?場合�?�LSB側を使用
    				read_pix( x_loop, y_loop, PIX_DATA, bmp_data );
    				RDATA <= PIX_DATA;
    			end loop;
    		end loop;
        end loop;

		wait;
	end process;

	-------------------------------
	-- ライト�?�メモリ
	process
		variable	bmp_data		: BMP_INFO;
		variable	biWidth			: integer;
		variable	biHeight		: integer;
		variable	biBitCount		: integer;
		variable	result		    : boolean;
	begin
		-- �?初に�?ず呼び出�?
		init_data( bmp_data );

		-- 「READ_BMP_FILE_NAME」を開き「bmp_data」に読み込�?
		-- ?��ライト用にリードと同じファイルを開く�?
		open_bmp( BMP_RD_FILE, bmp_data, result );
		if (result = FALSE) then
			assert false
			report "open_bmp fail."
			severity failure;
			wait;
		end if;

        -----------------
        -- FRM 1 START --
        -----------------
		-- ビット�?�ップ�?��?報を取得す�?
		get_info( bmp_data, biWidth, biHeight, biBitCount );

		-- ビット�?�ップ�?�左上座�?(0,0)から右�?(biWidth-1,biHeight-1)までルー�?
		for y_loop in 0 to biHeight-1 loop
			for x_loop in 0 to biWidth-1 loop
				wait until (WE = '1' and (CLK'event and CLK = '1'));

				-- ?��ピクセルの書き込み
				-- ?��ピクセルが３２Ｂ?��ｔに�?たな�?場合�?�LSB側を使用
				write_pix( x_loop, y_loop, WDATA, bmp_data );
			end loop;
		end loop;

		-- 「bmp_wdata」を「WRITE_BMP_FILE_NAME」へ書き込�?
		save_bmp( BMP_WR_FILE_FRM1, bmp_data, result );
		if ( result = FALSE ) then
			assert false
			report "save_bmp fail."
			severity failure;
			wait;
		end if;

        -----------------
        -- FRM 2 START --
        -----------------
		-- ビット�?�ップ�?��?報を取得す�?
		get_info( bmp_data, biWidth, biHeight, biBitCount );

		-- ビット�?�ップ�?�左上座�?(0,0)から右�?(biWidth-1,biHeight-1)までルー�?
		for y_loop in 0 to biHeight-1 loop
			for x_loop in 0 to biWidth-1 loop
				wait until (WE = '1' and (CLK'event and CLK = '1'));

				-- ?��ピクセルの書き込み
				-- ?��ピクセルが３２Ｂ?��ｔに�?たな�?場合�?�LSB側を使用
				write_pix( x_loop, y_loop, WDATA, bmp_data );
			end loop;
		end loop;

		-- 「bmp_wdata」を「WRITE_BMP_FILE_NAME」へ書き込�?
		save_bmp( BMP_WR_FILE_FRM2, bmp_data, result );
		if ( result = FALSE ) then
			assert false
			report "save_bmp fail."
			severity failure;
			wait;
		end if;

        -----------------
        -- FRM 3 START --
        -----------------
		-- ビット�?�ップ�?��?報を取得す�?
		get_info( bmp_data, biWidth, biHeight, biBitCount );

		-- ビット�?�ップ�?�左上座�?(0,0)から右�?(biWidth-1,biHeight-1)までルー�?
		for y_loop in 0 to biHeight-1 loop
			for x_loop in 0 to biWidth-1 loop
				wait until (WE = '1' and (CLK'event and CLK = '1'));

				-- ?��ピクセルの書き込み
				-- ?��ピクセルが３２Ｂ?��ｔに�?たな�?場合�?�LSB側を使用
				write_pix( x_loop, y_loop, WDATA, bmp_data );
			end loop;
		end loop;

		-- 「bmp_wdata」を「WRITE_BMP_FILE_NAME」へ書き込�?
		save_bmp( BMP_WR_FILE_FRM3, bmp_data, result );
		if ( result = FALSE ) then
			assert false
			report "save_bmp fail."
			severity failure;
			wait;
		end if;


		wait;
	end process;

end behavior;
