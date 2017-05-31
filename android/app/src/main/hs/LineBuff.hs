{-# LANGUAGE ForeignFunctionInterface #-}
module LineBuff where
import System.IO (hSetBuffering, BufferMode (LineBuffering), stdout)

-- on android, stdout is usually directed to /dev/null
-- and buffering is set to something unresonable.
-- We set buffering to line buffering.
foreign export ccall setLineBuffering :: IO ()
setLineBuffering :: IO ()
setLineBuffering = hSetBuffering stdout LineBuffering
