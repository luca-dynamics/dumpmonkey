import type { Metadata } from "next";
import type { ReactNode } from "react";
import { Anton, Inter } from "next/font/google";
import "./globals.css";

const anton = Anton({
  subsets: ["latin"],
  weight: "400",
  variable: "--font-display",
});

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-sans",
});

export const metadata: Metadata = {
  title: "DumpMonkey Crew | Race. Mine. Earn.",
  description:
    "DumpMonkey Crew is a mobile-first Web3 gaming and NFT IP ecosystem powered by MonkeyBike Racing, the DMC Mining App, $DUMP, and a community-first NFT collection.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${anton.variable} ${inter.variable}`}>{children}</body>
    </html>
  );
}
