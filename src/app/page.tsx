import { Ecosystem } from "@/components/Ecosystem";
import { FooterCTA } from "@/components/FooterCTA";
import { GameSection } from "@/components/GameSection";
import { Hero } from "@/components/Hero";
import { MiningApp } from "@/components/MiningApp";
import { Navbar } from "@/components/Navbar";
import { NFTSection } from "@/components/NFTSection";
import { Roadmap } from "@/components/Roadmap";
import { Team } from "@/components/Team";
import { TokenSection } from "@/components/TokenSection";

export default function Home() {
  return (
    <>
      <Navbar />
      <main>
        <Hero />
        <Ecosystem />
        <GameSection />
        <MiningApp />
        <TokenSection />
        <NFTSection />
        <Roadmap />
        <Team />
        <FooterCTA />
      </main>
    </>
  );
}
