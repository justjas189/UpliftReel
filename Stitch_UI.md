# Home - Recommendations
import { useMemo, useState } from "react";
import container from "./container.svg";
import icon from "./icon.svg";
import icon2 from "./icon-2.svg";
import icon3 from "./icon-3.svg";
import icon4 from "./icon-4.svg";
import icon5 from "./icon-5.svg";
import icon6 from "./icon-6.svg";
import icon7 from "./icon-7.svg";
import image from "./image.svg";

export const HomeRecommendations = (): JSX.Element => {
  const [watched, setWatched] = useState(false);

  const genres = useMemo(() => ["Comedy", "Adventure"], []);
  const streamingPlatforms = useMemo(
    () => [
      {
        label: "Netflix",
        short: "N",
        bg: "bg-[#e509141a]",
        text: "text-[#e50914]",
        width: "w-[9px]",
      },
      {
        label: "Prime Video",
        short: "P",
        bg: "bg-[#00a8e11a]",
        text: "text-[#00a8e1]",
        width: "w-[8.16px]",
      },
    ],
    [],
  );

  const bottomNavItems = useMemo(
    () => [
      {
        label: "Home",
        iconSrc: icon6,
        iconClassName: "w-4 h-[18px]",
        active: true,
        textClassName: "text-[#173b6c]",
        buttonClassName: "bg-sky-50 rounded-2xl",
        widthClassName: "w-[34.64px]",
      },
      {
        label: "Mood",
        iconSrc: icon7,
        iconClassName: "w-5 h-5",
        active: false,
        textClassName: "text-slate-400",
        buttonClassName: "",
        widthClassName: "w-[34.28px]",
      },
      {
        label: "Preferences",
        iconSrc: image,
        iconClassName: "w-[18px] h-[18px]",
        active: false,
        textClassName: "text-slate-400",
        buttonClassName: "",
        widthClassName: "w-[73.09px]",
      },
    ],
    [],
  );

  return (
    <div className="flex min-h-[1359px] flex-col items-start bg-[linear-gradient(0deg,rgba(244,243,248,1)_0%,rgba(244,243,248,1)_100%),linear-gradient(0deg,rgba(255,255,255,1)_0%,rgba(255,255,255,1)_100%)] px-0 pb-16 pt-20 relative">
      <header className="absolute left-0 top-0 flex h-16 w-[390px] items-center justify-between bg-[#ffffffe6] px-6 py-0 shadow-[0px_1px_2px_#0000000d] backdrop-blur-[6px] backdrop-brightness-[100%] [border-top-style:none] [border-right-style:none] [border-bottom-style:solid] [border-left-style:none] border-b border-slate-100 [-webkit-backdrop-filter:blur(6px)_brightness(100%)]">
        <button
          type="button"
          aria-label="Open menu"
          className="inline-flex flex-[0_0_auto] flex-col items-center justify-center rounded-full p-2 relative"
        >
          <span className="inline-flex flex-[0_0_auto] items-start justify-center relative">
            <img className="relative h-3 w-[18px]" alt="" src={icon5} />
          </span>
        </button>
        <div className="inline-flex flex-[0_0_auto] flex-col items-start relative">
          <div className="relative mt-[-1.00px] flex h-8 w-[115.92px] items-center whitespace-nowrap [font-family:'Be_Vietnam_Pro-Black',Helvetica] text-2xl font-black leading-8 tracking-[-1.20px] text-[#173b6c]">
            Uplift Reel
          </div>
        </div>
        <button
          type="button"
          aria-label="Open profile"
          className="flex h-8 w-8 flex-col items-start justify-center overflow-hidden rounded-full border border-solid border-[#c3c6d0] relative"
        >
          <div className="relative grow self-stretch bg-[url(/user-profile-profile.png)] bg-cover bg-[50%_50%] w-full flex-1" />
        </button>
      </header>
      <main className="relative flex w-full max-w-md flex-[0_0_auto] flex-col items-start gap-6 px-4 py-0">
        <section className="relative flex w-full flex-[0_0_auto] flex-col items-start gap-2 px-0 py-4 self-stretch">
          <h1 className="relative mt-[-1.00px] flex h-9 w-[171.75px] items-center whitespace-nowrap [font-family:'Be_Vietnam_Pro-SemiBold',Helvetica] text-3xl font-semibold leading-9 tracking-[0] text-[#173b6c]">
            Need a lift?
          </h1>
          <div className="relative inline-flex flex-[0_0_auto] flex-col items-start px-0 pb-2 pt-0">
            <p className="relative mt-[-1.00px] flex h-6 w-[341.58px] items-center whitespace-nowrap [font-family:'Be_Vietnam_Pro-Regular',Helvetica] text-base font-normal leading-6 tracking-[0] text-[#43474f]">
              Find the perfect movie for your current vibe.
            </p>
          </div>
          <button
            type="button"
            aria-label="Set mood"
            className="inline-flex flex-[0_0_auto] items-center gap-2 rounded-full bg-[#ff6a3d] px-6 py-3 shadow-[0px_1px_2px_#0000000d] relative"
          >
            <span className="inline-flex flex-[0_0_auto] flex-col items-center relative">
              <img className="relative h-5 w-5" alt="" src={icon} />
            </span>
            <span className="inline-flex flex-[0_0_auto] flex-col items-center relative">
              <span className="relative flex h-6 w-[76.02px] items-center justify-center whitespace-nowrap [font-family:'Be_Vietnam_Pro-SemiBold',Helvetica] text-base font-semibold leading-6 tracking-[0] text-center text-white">
                Set Mood
              </span>
            </span>
          </button>
        </section>
        <section className="relative flex w-full flex-[0_0_auto] flex-col items-start gap-4 self-stretch">
          <div className="relative flex w-full flex-[0_0_auto] flex-col items-start self-stretch">
            <h2 className="relative mt-[-1.00px] flex items-center self-stretch [font-family:'Be_Vietnam_Pro-SemiBold',Helvetica] text-xl font-semibold leading-[26px] tracking-[0] text-[#1a1c1f]">
              Top Pick For You
            </h2>
          </div>
          <article className="relative flex aspect-[0.8] w-full flex-[0_0_auto] flex-col items-start justify-center overflow-hidden rounded-[22px] bg-[#ffffff01] shadow-[0px_4px_6px_-4px_#0000001a,0px_10px_15px_-3px_#0000001a] self-stretch">
            <div
              className="relative h-[447.5px] w-full self-stretch bg-[url(/movie-poster.png)] bg-cover bg-[50%_50%]"
              role="img"
              aria-label="The Grand Budapest Hotel poster"
            />
            <div className="absolute left-0 top-0 h-full w-full bg-[linear-gradient(0deg,rgba(33,37,41,1)_0%,rgba(33,37,41,0.6)_50%,rgba(33,37,41,0)_100%)]">
              <div className="absolute left-6 top-[271px] flex w-[calc(100%_-_48px)] flex-col items-start px-0 pb-2 pt-0">
                <div className="relative flex w-full flex-[0_0_auto] flex-col items-start self-stretch">
                  <h3 className="relative mt-[-1.00px] self-stretch [font-family:'Be_Vietnam_Pro-SemiBold',Helvetica] text-4xl font-semibold leading-[45px] tracking-[0] text-white">
                    The Grand
                    <br />
                    Budapest Hotel
                  </h3>
                </div>
              </div>
              <div className="absolute left-6 top-[369px] flex w-[calc(100%_-_48px)] flex-col items-start px-0 pb-2 pt-0">
                <div className="relative flex w-full flex-[0_0_auto] items-start gap-2 self-stretch">
                  {genres.map((genre) => (
                    <div
                      key={genre}
                      className="inline-flex flex-[0_0_auto] self-stretch rounded-full border border-solid border-[#ffffff1a] bg-[#ffffff33] px-3 pb-[4.8px] pt-[3px] backdrop-blur-[6px] backdrop-brightness-[100%] relative [-webkit-backdrop-filter:blur(6px)_brightness(100%)]"
                    >
                      <div className="relative flex h-[17px] items-center whitespace-nowrap [font-family:'Be_Vietnam_Pro-Regular',Helvetica] text-xs font-normal leading-[16.8px] tracking-[0] text-white">
                        {genre}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
              <div className="absolute bottom-6 left-6 flex w-[calc(100%_-_48px)] flex-col items-start px-0 pb-[0.59px] pt-0 opacity-90">
                <div className="relative mt-[-1.00px] flex h-5 w-[96.13px] items-center whitespace-nowrap [font-family:'Be_Vietnam_Pro-Regular',Helvetica] text-sm font-normal leading-[19.6px] tracking-[0] text-[#e9ecef]">
                  2014 • 1h 39m
                </div>
              </div>
            </div>
          </article>
        </section>
        <section
          className="grid h-fit grid-cols-2 grid-rows-[183.34px_120.80px] gap-2"
          aria-label="Movie details"
        >
          <article className="relative col-[1_/_3] row-[1_/_2] flex h-fit w-full flex-col items-start gap-2 rounded-xl border border-solid border-[#e3e2e7] bg-white px-5 pb-5 pt-[19px] shadow-[0px_2px_10px_#00000008]">
            <div className="relative flex w-full flex-[0_0_auto] flex-col items-start self-stretch px-0 pb-[0.59px] pt-0">
              <div className="relative mt-[-1.00px] flex items-center self-stretch [font-family:'Be_Vietnam_Pro-SemiBold',Helvetica] text-sm font-semibold leading-[19.6px] tracking-[0.70px] text-[#173b6c]">
                SYNOPSIS
              </div>
            </div>
            <div className="relative flex w-full flex-[0_0_auto] flex-col items-start self-stretch">
              <p className="relative mt-[-1.00px] self-stretch [font-family:'Be_Vietnam_Pro-Regular',Helvetica] text-sm font-normal leading-[22.8px] tracking-[0] text-[#43474f]">
                A writer encounters the owner of an aging
                <br />
                high-class hotel, who tells him of his early
                <br />
                years serving as a lobby boy in the hotel&#39;s
                <br />
                glorious years under an exceptional
                <br />
                concierge.
              </p>
            </div>
          </article>
          <article className="relative col-[1_/_2] row-[2_/_3] flex h-fit w-full flex-col items-center justify-center rounded-xl border border-solid border-[#e3e2e7] bg-white p-5 shadow-[0px_2px_10px_#00000008]">
            <div className="relative inline-flex flex-[0_0_auto] flex-col items-start px-0 pb-1 pt-0">
              <div className="relative mt-[-1.00px] flex h-[17px] w-[49.72px] items-center whitespace-nowrap [font-family:'Be_Vietnam_Pro-SemiBold',Helvetica] text-xs font-semibold leading-[16.8px] tracking-[0.60px] text-[#43474f]">
                RATING
              </div>
            </div>
            <div className="relative inline-flex flex-[0_0_auto] flex-col items-start px-0 pb-1 pt-0">
              <div className="relative h-9 w-[63.61px]">
                <div className="absolute left-0 top-0 flex h-9 w-[42px] items-center whitespace-nowrap [font-family:'Be_Vietnam_Pro-SemiBold',Helvetica] text-3xl font-semibold leading-9 tracking-[0] text-[#173b6c]">
                  8.1
                </div>
                <div className="absolute left-[42px] top-3.5 flex h-5 w-[22px] items-center whitespace-nowrap [font-family:'Be_Vietnam_Pro-Regular',Helvetica] text-sm font-normal leading-[19.6px] tracking-[0] text-[#747780]">
                  /10
                </div>
              </div>
            </div>
            <img
              className="relative flex-[0_0_auto]"
              alt="Rating stars"
              src={container}
            />
          </article>
          <article className="relative col-[2_/_3] row-[2_/_3] flex h-fit w-full flex-col items-center justify-center gap-[6.75e-14px] rounded-xl border border-solid border-[#e3e2e7] bg-white px-5 py-[25px] shadow-[0px_2px_10px_#00000008]">
            <div className="relative inline-flex flex-[0_0_auto] flex-col items-start px-0 pb-3 pt-0">
              <div className="relative mt-[-1.00px] flex h-[17px] w-[78.33px] items-center whitespace-nowrap [font-family:'Be_Vietnam_Pro-SemiBold',Helvetica] text-xs font-semibold leading-[16.8px] tracking-[0.60px] text-[#43474f]">
                STREAM ON
              </div>
            </div>
            <div className="relative inline-flex flex-[0_0_auto] items-start justify-center gap-3">
              {streamingPlatforms.map((platform) => (
                <div
                  key={platform.label}
                  className={`relative flex h-10 w-10 items-center justify-center rounded-full ${platform.bg} px-0 pb-[11.61px] pt-[10.59px]`}
                  aria-label={platform.label}
                  title={platform.label}
                >
                  <div className="relative inline-flex flex-[0_0_auto] flex-col items-start px-0 pb-[0.8px] pt-0">
                    <div
                      className={`relative mt-[-1.00px] flex h-[17px] ${platform.width} items-center whitespace-nowrap [font-family:'Be_Vietnam_Pro-Bold',Helvetica] text-xs font-bold leading-[16.8px] tracking-[0] ${platform.text}`}
                    >
                      {platform.short}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </article>
        </section>
        <section className="relative flex w-full flex-[0_0_auto] flex-col items-start gap-3 self-stretch px-0 pb-0 pt-2">
          <div className="relative flex w-full flex-[0_0_auto] items-start justify-center gap-3 self-stretch">
            <button
              type="button"
              className="relative flex h-[52px] w-[174px] items-center justify-center gap-[7.99px] rounded-lg border-2 border-solid border-[#173b6c]"
              aria-label="Watch trailer"
            >
              <span className="relative inline-flex flex-[0_0_auto] flex-col items-center">
                <img className="relative h-5 w-5" alt="" src={icon2} />
              </span>
              <span className="relative flex h-6 w-[107.89px] items-center justify-center whitespace-nowrap [font-family:'Be_Vietnam_Pro-SemiBold',Helvetica] text-base font-semibold leading-6 tracking-[0] text-center text-[#173b6c]">
                Watch Trailer
              </span>
            </button>
            <button
              type="button"
              className="relative flex h-[52px] w-[172px] items-center justify-center gap-2 rounded-lg border border-solid border-[#e3e2e7] bg-white shadow-[0px_1px_2px_#0000000d]"
              aria-label="View details"
            >
              <span className="relative inline-flex flex-[0_0_auto] flex-col items-center">
                <img className="relative h-5 w-5" alt="" src={icon3} />
              </span>
              <span className="relative flex h-6 w-[99.56px] items-center justify-center whitespace-nowrap [font-family:'Be_Vietnam_Pro-SemiBold',Helvetica] text-base font-semibold leading-6 tracking-[0] text-center text-[#173b6c]">
                View Details
              </span>
            </button>
          </div>
          <button
            type="button"
            aria-pressed={watched}
            onClick={() => setWatched((prev) => !prev)}
            className="relative flex h-[60px] w-full items-center justify-center gap-2 rounded-lg bg-[#173b6c] self-stretch"
          >
            <div className="absolute left-0 top-0 h-[60px] w-full rounded-lg bg-[#ffffff01] shadow-[0px_2px_4px_-2px_#0000001a,0px_4px_6px_-1px_#0000001a]" />
            <span className="relative inline-flex flex-[0_0_auto] flex-col items-center">
              <img
                className="relative h-[12.03px] w-[21.9px]"
                alt=""
                src={icon4}
              />
            </span>
            <span className="relative flex h-[27px] w-[99.86px] items-center justify-center whitespace-nowrap [font-family:'Be_Vietnam_Pro-Bold',Helvetica] text-center text-lg font-bold leading-[27px] tracking-[0] text-white">
              {watched ? "Watched" : "Watched It"}
            </span>
          </button>
          <div className="relative flex h-14 w-full flex-col items-start self-stretch px-0 pb-0 pt-2">
            <button
              type="button"
              className="relative flex h-12 w-full items-center justify-center self-stretch"
              aria-label="Skip for now"
            >
              <span className="relative flex h-6 w-[96.34px] items-center justify-center whitespace-nowrap [font-family:'Be_Vietnam_Pro-Regular',Helvetica] text-base font-normal leading-6 tracking-[0] text-center text-[#43474f]">
                Skip for now
              </span>
            </button>
          </div>
        </section>
      </main>
      <nav
        aria-label="Bottom navigation"
        className="absolute bottom-[23px] left-0 flex w-[390px] items-center gap-6 rounded-[16px_16px_0px_0px] border-t border-slate-100 bg-white pb-6 pl-[27.98px] pr-[28.03px] pt-3 shadow-[0px_-8px_30px_#0000000a] [border-top-style:solid]"
      >
        {bottomNavItems.map((item, index) => (
          <button
            key={item.label}
            type="button"
            aria-current={item.active ? "page" : undefined}
            className={`inline-flex flex-[0_0_auto] flex-col items-center justify-center gap-[3px] px-6 pb-[8.8px] pt-2 relative ${item.buttonClassName} ${index === 2 ? "mr-[-0.02px]" : ""}`}
          >
            <span className="relative inline-flex flex-[0_0_auto] flex-col items-center">
              <img
                className={`relative ${item.iconClassName}`}
                alt=""
                src={item.iconSrc}
              />
            </span>
            <span
              className={`relative flex h-[17px] ${item.widthClassName} items-center justify-center whitespace-nowrap [font-family:'Be_Vietnam_Pro-Bold',Helvetica] text-xs font-bold leading-[16.8px] tracking-[0] text-center ${item.textClassName}`}
            >
              {item.label}
            </span>
          </button>
        ))}
      </nav>
    </div>
  );
};

export default HomeRecommendations;

tailwind.config.js:
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{html,js,ts,jsx,tsx}"],
  theme: {
    extend: {},
  },
  plugins: [],
};

tailwind.css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  button,
  input,
  select,
  textarea {
    @apply appearance-none bg-transparent border-0 outline-none;
  }
}

@tailwind components;
@tailwind utilities;

@layer components {
  .all-\[unset\] {
    all: unset;
  }
}

:root {
  --animate-spin: spin 1s linear infinite;
}

.animate-fade-in {
  animation: fade-in 1s var(--animation-delay, 0s) ease forwards;
}

.animate-fade-up {
  animation: fade-up 1s var(--animation-delay, 0s) ease forwards;
}

.animate-marquee {
  animation: marquee var(--duration) infinite linear;
}

.animate-marquee-vertical {
  animation: marquee-vertical var(--duration) linear infinite;
}

.animate-shimmer {
  animation: shimmer 8s infinite;
}

.animate-spin {
  animation: var(--animate-spin);
}

@keyframes spin {
  to {
    transform: rotate(1turn);
  }
}

@keyframes image-glow {
  0% {
    opacity: 0;
    animation-timing-function: cubic-bezier(0.74, 0.25, 0.76, 1);
  }

  10% {
    opacity: 0.7;
    animation-timing-function: cubic-bezier(0.12, 0.01, 0.08, 0.99);
  }

  to {
    opacity: 0.4;
  }
}

@keyframes fade-in {
  0% {
    opacity: 0;
    transform: translateY(-10px);
  }

  to {
    opacity: 1;
    transform: none;
  }
}

@keyframes fade-up {
  0% {
    opacity: 0;
    transform: translateY(20px);
  }

  to {
    opacity: 1;
    transform: none;
  }
}

@keyframes shimmer {
  0%,
  90%,
  to {
    background-position: calc(-100% - var(--shimmer-width)) 0;
  }

  30%,
  60% {
    background-position: calc(100% + var(--shimmer-width)) 0;
  }
}

@keyframes marquee {
  0% {
    transform: translate(0);
  }

  to {
    transform: translateX(calc(-100% - var(--gap)));
  }
}

@keyframes marquee-vertical {
  0% {
    transform: translateY(0);
  }

  to {
    transform: translateY(calc(-100% - var(--gap)));
  }
}

# Set Mood
import icon10 from "./icon-10.svg";
import { MobileNavigationSection } from "./MobileNavigationSection";
import { MoodAndPreferencesSection } from "./MoodAndPreferencesSection";

export const SetMood = (): JSX.Element => {
  return (
    <main className="flex flex-col min-h-[1474px] items-start pt-16 pb-24 px-0 relative bg-[linear-gradient(0deg,rgba(248,249,250,1)_0%,rgba(248,249,250,1)_100%),linear-gradient(0deg,rgba(255,255,255,1)_0%,rgba(255,255,255,1)_100%)]">
      <header className="flex w-[390px] h-16 items-center justify-between pl-6 pr-[24.02px] py-0 absolute top-0 left-0 bg-[#ffffffe6] border-b [border-bottom-style:solid] border-slate-100 shadow-[0px_1px_2px_#0000000d] backdrop-blur-[6px] backdrop-brightness-[100%] [-webkit-backdrop-filter:blur(6px)_brightness(100%)] z-10">
        <button
          type="button"
          aria-label="Open navigation menu"
          className="relative w-[32.02px] h-10"
        >
          <span className="inline-flex flex-col items-center justify-center p-2 relative -left-2 rounded-full">
            <span className="inline-flex items-start justify-center relative flex-[0_0_auto]">
              <img className="relative w-[18px] h-3" alt="" src={icon10} />
            </span>
          </span>
        </button>
        <div className="inline-flex flex-col items-start relative flex-[0_0_auto]">
          <h1 className="relative flex items-center w-[122.53px] h-8 mt-[-1.00px] [font-family:'Be_Vietnam_Pro-Black',Helvetica] font-black text-[#173b6c] text-2xl tracking-[-0.60px] leading-8 whitespace-nowrap">
            Uplift Reel
          </h1>
        </div>
        <button
          type="button"
          aria-label="Open user profile"
          className="inline-flex flex-col items-start relative flex-[0_0_auto]"
        >
          <span
            className="relative w-8 h-8 rounded-full border border-solid border-slate-200 bg-[url(/user-profile.png)] bg-cover bg-[50%_50%]"
            aria-hidden="true"
          />
        </button>
      </header>
      <MoodAndPreferencesSection />
      <MobileNavigationSection />
    </main>
  );
};

export default SetMood;


MobileNavigationSection.tsx
import icon11 from "./icon-11.svg";
import icon12 from "./icon-12.svg";
import icon13 from "./icon-13.svg";

const navigationItems = [
  {
    label: "Home",
    icon: icon11,
    iconClassName: "w-4 h-[18px]",
    textClassName: "text-slate-400",
    itemClassName:
      "inline-flex flex-col items-center justify-center px-6 py-2 relative flex-[0_0_auto]",
    widthClassName: "w-[34.64px]",
    isActive: false,
  },
  {
    label: "Mood",
    icon: icon12,
    iconClassName: "w-5 h-5",
    textClassName: "text-[#173b6c]",
    itemClassName:
      "bg-sky-50 rounded-2xl inline-flex flex-col items-center justify-center px-6 py-2 relative flex-[0_0_auto]",
    widthClassName: "w-[34.28px]",
    isActive: true,
  },
  {
    label: "Preferences",
    icon: icon13,
    iconClassName: "w-[18px] h-[18px]",
    textClassName: "text-slate-400",
    itemClassName:
      "mr-[-0.02px] inline-flex flex-col items-center justify-center px-6 py-2 relative flex-[0_0_auto]",
    widthClassName: "w-[73.09px]",
    isActive: false,
  },
];

export const MobileNavigationSection = (): JSX.Element => {
  return (
    <nav
      aria-label="Mobile navigation"
      className="flex w-[390px] items-center gap-6 pl-[27.98px] pr-[28.03px] pt-3 pb-6 absolute left-0 bottom-[19px] bg-white rounded-[16px_16px_0px_0px] border-t [border-top-style:solid] border-slate-100 shadow-[0px_-8px_30px_#0000000a]"
    >
      {navigationItems.map((item) => (
        <button
          key={item.label}
          type="button"
          aria-current={item.isActive ? "page" : undefined}
          className={item.itemClassName}
        >
          <span className="inline-flex flex-col items-start pt-0 pb-1 px-0 relative flex-[0_0_auto]">
            <img
              className={`relative ${item.iconClassName}`}
              alt=""
              src={item.icon}
              aria-hidden="true"
            />
          </span>
          <span className="inline-flex flex-col items-start pt-0 pb-[0.8px] px-0 relative flex-[0_0_auto] -mt-px">
            <span
              className={`relative flex items-center ${item.widthClassName} h-[17px] mt-[-1.00px] [font-family:'Be_Vietnam_Pro-Bold',Helvetica] font-bold ${item.textClassName} text-xs tracking-[0] leading-[16.8px] whitespace-nowrap`}
            >
              {item.label}
            </span>
          </span>
        </button>
      ))}
    </nav>
  );
};

MoodandPreferencesSection.tsx
import { useId, useState } from "react";
import icon from "./icon.svg";
import icon2 from "./icon-2.svg";
import icon3 from "./icon-3.svg";
import icon4 from "./icon-4.svg";
import icon5 from "./icon-5.svg";
import icon6 from "./icon-6.svg";
import icon7 from "./icon-7.svg";
import icon8 from "./icon-8.svg";
import icon9 from "./icon-9.svg";
import image from "./image.svg";

type MoodItem = {
  id: string;
  label: string;
  subtitle: string;
  iconSrc: string;
  iconClassName: string;
  titleWidthClass: string;
  titleLeftClass: string;
  subtitleWidthClass: string;
  subtitleLeftClass: string;
  titleTextClass: string;
  subtitleTextClass: string;
};

type EnergyOption = {
  id: string;
  label: string;
  multiline?: boolean;
  buttonClassName: string;
  textClassName: string;
};

type TimeOption = {
  id: string;
  label: string;
  buttonClassName: string;
  textClassName: string;
};

const moods: MoodItem[] = [
  {
    id: "happy",
    label: "Happy",
    subtitle: "Comedy, Feel-Good",
    iconSrc: icon,
    iconClassName: "relative w-[30px] h-[30px]",
    titleWidthClass: "w-[52.11px]",
    titleLeftClass: "left-[calc(50.00%_-_26px)]",
    subtitleWidthClass: "w-[120.25px]",
    subtitleLeftClass: "left-[calc(50.00%_-_60px)]",
    titleTextClass: "text-[#173b6c]",
    subtitleTextClass: "text-[#254778]",
  },
  {
    id: "relaxed",
    label: "Relaxed",
    subtitle: "Drama, Nature",
    iconSrc: icon2,
    iconClassName: "relative w-[30px] h-[30px]",
    titleWidthClass: "w-[64.08px]",
    titleLeftClass: "left-[calc(50.00%_-_32px)]",
    subtitleWidthClass: "w-[85.08px]",
    subtitleLeftClass: "left-[calc(50.00%_-_43px)]",
    titleTextClass: "text-[#1a1c1f]",
    subtitleTextClass: "text-[#43474f]",
  },
  {
    id: "excited",
    label: "Excited",
    subtitle: "Action, Adventure",
    iconSrc: icon3,
    iconClassName: "relative w-[32.33px] h-[30.75px]",
    titleWidthClass: "w-[60.64px]",
    titleLeftClass: "left-[calc(50.00%_-_30px)]",
    subtitleWidthClass: "w-[105.48px]",
    subtitleLeftClass: "left-[calc(50.00%_-_53px)]",
    titleTextClass: "text-[#1a1c1f]",
    subtitleTextClass: "text-[#43474f]",
  },
  {
    id: "thoughtful",
    label: "Thoughtful",
    subtitle: "Documentary, Sci-Fi",
    iconSrc: icon4,
    iconClassName: "relative w-[28.52px] h-[30px]",
    titleWidthClass: "w-[86.63px]",
    titleLeftClass: "left-[calc(50.00%_-_43px)]",
    subtitleWidthClass: "w-[121.98px]",
    subtitleLeftClass: "left-[calc(50.00%_-_61px)]",
    titleTextClass: "text-[#1a1c1f]",
    subtitleTextClass: "text-[#43474f]",
  },
  {
    id: "melancholy",
    label: "Melancholy",
    subtitle: "Romance, Indie",
    iconSrc: icon5,
    iconClassName: "relative w-6 h-[30px]",
    titleWidthClass: "w-[91.69px]",
    titleLeftClass: "left-[calc(50.00%_-_46px)]",
    subtitleWidthClass: "w-[89.52px]",
    subtitleLeftClass: "left-[calc(50.00%_-_45px)]",
    titleTextClass: "text-[#1a1c1f]",
    subtitleTextClass: "text-[#43474f]",
  },
  {
    id: "thrilled",
    label: "Thrilled",
    subtitle: "Thriller, Horror",
    iconSrc: icon6,
    iconClassName: "relative w-6 h-[30px]",
    titleWidthClass: "w-[60.95px]",
    titleLeftClass: "left-[calc(50.00%_-_30px)]",
    subtitleWidthClass: "w-[84.88px]",
    subtitleLeftClass: "left-[calc(50.00%_-_42px)]",
    titleTextClass: "text-[#1a1c1f]",
    subtitleTextClass: "text-[#43474f]",
  },
  {
    id: "cozy",
    label: "Cozy",
    subtitle: "Family, Classic",
    iconSrc: icon7,
    iconClassName: "relative w-[30px] h-[30px]",
    titleWidthClass: "w-[40.58px]",
    titleLeftClass: "left-[calc(50.00%_-_20px)]",
    subtitleWidthClass: "w-[87.83px]",
    subtitleLeftClass: "left-[calc(50.00%_-_44px)]",
    titleTextClass: "text-[#1a1c1f]",
    subtitleTextClass: "text-[#43474f]",
  },
  {
    id: "curious",
    label: "Curious",
    subtitle: "Mystery, History",
    iconSrc: icon8,
    iconClassName: "relative w-[30px] h-[30px]",
    titleWidthClass: "w-[61.39px]",
    titleLeftClass: "left-[calc(50.00%_-_31px)]",
    subtitleWidthClass: "w-[95.23px]",
    subtitleLeftClass: "left-[calc(50.00%_-_48px)]",
    titleTextClass: "text-[#1a1c1f]",
    subtitleTextClass: "text-[#43474f]",
  },
];

const energyOptions: EnergyOption[] = [
  {
    id: "low-key",
    label: "Low Key",
    buttonClassName:
      "flex flex-col w-[98px] items-center justify-center pt-[20.8px] pb-[22.39px] px-2 relative rounded-lg border border-solid border-[#c3c6d0]",
    textClassName:
      "relative flex items-center justify-center w-[57.16px] h-5 [font-family:'Be_Vietnam_Pro-Regular',Helvetica] font-normal text-[#1a1c1f] text-sm text-center tracking-[0] leading-[19.6px] whitespace-nowrap",
  },
  {
    id: "balanced",
    label: "Balanced",
    buttonClassName:
      "flex flex-col w-24 items-center justify-center pt-[21.8px] pb-[23.39px] px-2 relative bg-[#173b6c] rounded-lg",
    textClassName:
      "relative flex items-center justify-center w-[65.03px] h-5 mt-[-1.00px] [font-family:'Be_Vietnam_Pro-Regular',Helvetica] font-normal text-white text-sm text-center tracking-[0] leading-[19.6px] whitespace-nowrap",
  },
  {
    id: "high-energy",
    label: "High Energy",
    multiline: true,
    buttonClassName:
      "flex flex-col w-[98px] items-center justify-center pt-[10.8px] pb-[12.4px] px-2 relative rounded-lg border border-solid border-[#c3c6d0]",
    textClassName:
      "relative w-[47.18px] h-10 [font-family:'Be_Vietnam_Pro-Regular',Helvetica] font-normal text-[#1a1c1f] text-sm text-center tracking-[0] leading-[19.6px]",
  },
];

const timeOptions: TimeOption[] = [
  {
    id: "under-90",
    label: "< 90 mins",
    buttonClassName:
      "inline-flex flex-col items-center justify-center px-4 py-2 absolute top-0 left-0 rounded-full border border-solid border-[#c3c6d0]",
    textClassName:
      "relative flex items-center justify-center w-[64.55px] h-5 [font-family:'Be_Vietnam_Pro-Regular',Helvetica] font-normal text-[#1a1c1f] text-sm text-center tracking-[0] leading-[19.6px] whitespace-nowrap",
  },
  {
    id: "90-120",
    label: "90 - 120 mins",
    buttonClassName:
      "inline-flex flex-col items-center justify-center px-4 py-2 absolute top-0 left-[107px] bg-[#d6e3ff] rounded-full border border-solid border-[#173b6c]",
    textClassName:
      "relative flex items-center justify-center w-[93.47px] h-5 [font-family:'Be_Vietnam_Pro-Medium',Helvetica] font-medium text-[#173b6c] text-sm text-center tracking-[0] leading-[19.6px] whitespace-nowrap",
  },
  {
    id: "120-plus",
    label: "120+ mins",
    buttonClassName:
      "inline-flex flex-col items-center justify-center px-4 py-2 absolute top-[46px] left-0 rounded-full border border-solid border-[#c3c6d0]",
    textClassName:
      "relative flex items-center justify-center w-[67.05px] h-5 [font-family:'Be_Vietnam_Pro-Regular',Helvetica] font-normal text-[#1a1c1f] text-sm text-center tracking-[0] leading-[19.6px] whitespace-nowrap",
  },
  {
    id: "whole-series",
    label: "A Whole Series",
    buttonClassName:
      "inline-flex flex-col items-center justify-center px-4 py-2 absolute top-[46px] left-[109px] rounded-full border border-solid border-[#c3c6d0]",
    textClassName:
      "relative flex items-center justify-center w-[102.17px] h-5 [font-family:'Be_Vietnam_Pro-Regular',Helvetica] font-normal text-[#1a1c1f] text-sm text-center tracking-[0] leading-[19.6px] whitespace-nowrap",
  },
];

export const MoodAndPreferencesSection = (): JSX.Element => {
  const [selectedMood, setSelectedMood] = useState<string>("happy");
  const [selectedEnergy, setSelectedEnergy] = useState<string>("balanced");
  const [selectedTime, setSelectedTime] = useState<string>("90-120");

  const headingId = useId();
  const moodDescriptionId = useId();
  const moodGroupId = useId();
  const energyGroupId = useId();
  const timeGroupId = useId();

  return (
    <section
      aria-labelledby={headingId}
      className="flex flex-col max-w-4xl items-start gap-8 px-4 py-6 relative w-full flex-[0_0_auto]"
    >
      <div className="flex flex-col items-start pt-4 pb-0 px-0 relative self-stretch w-full flex-[0_0_auto]">
        <div className="flex flex-col items-start gap-2 relative self-stretch w-full flex-[0_0_auto]">
          <div className="flex flex-col items-center relative self-stretch w-full flex-[0_0_auto]">
            <h2
              id={headingId}
              className="relative flex items-center justify-center w-[310.81px] h-9 mt-[-1.00px] [font-family:'Be_Vietnam_Pro-SemiBold',Helvetica] font-semibold text-[#173b6c] text-3xl text-center tracking-[0] leading-9 whitespace-nowrap"
            >
              How are you feeling?
            </h2>
          </div>
          <div className="flex flex-col items-center relative self-stretch w-full flex-[0_0_auto]">
            <p
              id={moodDescriptionId}
              className="relative w-[303.34px] h-[54px] mt-[-1.00px] [font-family:'Be_Vietnam_Pro-Medium',Helvetica] font-medium text-[#43474f] text-lg text-center tracking-[0] leading-[27px]"
            >
              Select a mood to get personalized
              <br />
              movie recommendations.
            </p>
          </div>
        </div>
      </div>
      <div
        role="radiogroup"
        aria-labelledby={headingId}
        aria-describedby={moodDescriptionId}
        id={moodGroupId}
        className="grid grid-cols-2 grid-rows-[128px_128px_128px_128px] h-fit gap-2"
      >
        {moods.map((mood, index) => {
          const isSelected = selectedMood === mood.id;
          const row = Math.floor(index / 2) + 1;
          const col = (index % 2) + 1;

          return (
            <button
              key={mood.id}
              type="button"
              role="radio"
              aria-checked={isSelected}
              aria-label={`${mood.label}: ${mood.subtitle}`}
              onClick={() => setSelectedMood(mood.id)}
              className={`relative row-[${row}_/_${row + 1}] col-[${col}_/_${col + 1}] w-[175px] h-32 rounded-xl shadow-[0px_1px_2px_#0000000d] ${
                isSelected
                  ? "bg-[#d6e3ff] border-2 border-solid border-[#173b6c]"
                  : "bg-white border border-solid border-[#c3c6d0]"
              }`}
            >
              <div className="inline-flex flex-col items-start pt-0 pb-1 px-0 absolute top-[18px] left-[70px]">
                <div className="inline-flex flex-col items-center relative flex-[0_0_auto]">
                  <img
                    className={mood.iconClassName}
                    alt=""
                    aria-hidden="true"
                    src={mood.iconSrc}
                  />
                </div>
              </div>
              <div
                className={`inline-flex flex-col items-center absolute top-[calc(50.00%_+_2px)] ${mood.titleLeftClass}`}
              >
                <div
                  className={`relative flex items-center justify-center ${mood.titleWidthClass} h-6 mt-[-1.00px] [font-family:'Be_Vietnam_Pro-SemiBold',Helvetica] font-semibold ${mood.titleTextClass} text-base text-center tracking-[0] leading-6 whitespace-nowrap`}
                >
                  {mood.label}
                </div>
              </div>
              <div
                className={`inline-flex flex-col items-center pt-0 pb-[0.8px] px-0 absolute top-[calc(50.00%_+_29px)] ${mood.subtitleLeftClass} opacity-80`}
              >
                <div
                  className={`relative flex items-center justify-center ${mood.subtitleWidthClass} h-[17px] mt-[-1.00px] [font-family:'Be_Vietnam_Pro-Regular',Helvetica] font-normal ${mood.subtitleTextClass} text-xs text-center tracking-[0] leading-[16.8px] whitespace-nowrap`}
                >
                  {mood.subtitle}
                </div>
              </div>
              {isSelected && (
                <div className="flex w-6 h-6 items-center justify-center pt-[1.2px] pb-[2.21px] px-0 absolute top-2.5 right-2.5 bg-[#173b6c] rounded-full shadow-[0px_1px_2px_#0000000d]">
                  <div className="inline-flex flex-col items-center pt-0 pb-[0.59px] px-0 relative flex-[0_0_auto]">
                    <img
                      className="relative w-[9.51px] h-[7.01px]"
                      alt=""
                      aria-hidden="true"
                      src={image}
                    />
                  </div>
                </div>
              )}
            </button>
          );
        })}
      </div>
      <section className="flex flex-col items-start gap-4 p-6 relative self-stretch w-full flex-[0_0_auto] bg-white rounded-2xl border border-solid border-[#c3c6d0] shadow-[0px_1px_2px_#0000000d]">
        <div className="flex flex-col items-start relative self-stretch w-full flex-[0_0_auto]">
          <h3
            id={energyGroupId}
            className="relative flex items-center self-stretch mt-[-1.00px] [font-family:'Be_Vietnam_Pro-SemiBold',Helvetica] font-semibold text-[#173b6c] text-xl tracking-[0] leading-[26px]"
          >
            Energy Level
          </h3>
        </div>
        <div
          role="radiogroup"
          aria-labelledby={energyGroupId}
          className="flex items-start justify-center gap-2 relative self-stretch w-full flex-[0_0_auto]"
        >
          {energyOptions.map((option) => {
            const isSelected = selectedEnergy === option.id;

            return (
              <button
                key={option.id}
                type="button"
                role="radio"
                aria-checked={isSelected}
                onClick={() => setSelectedEnergy(option.id)}
                className={
                  isSelected
                    ? "all-[unset] box-border flex flex-col w-24 items-center justify-center pt-[21.8px] pb-[23.39px] px-2 relative bg-[#173b6c] rounded-lg"
                    : `all-[unset] box-border ${option.buttonClassName}`
                }
              >
                {isSelected && (
                  <div className="absolute w-full h-full top-0 left-0 bg-[#ffffff01] rounded-lg shadow-[0px_2px_4px_-2px_#0000001a,0px_4px_6px_-1px_#0000001a]" />
                )}
                <div
                  className={
                    isSelected
                      ? energyOptions[1].textClassName
                      : option.textClassName
                  }
                >
                  {option.multiline ? (
                    <>
                      High
                      <br />
                      Energy
                    </>
                  ) : (
                    option.label
                  )}
                </div>
              </button>
            );
          })}
        </div>
      </section>
      <section className="flex flex-col items-start gap-4 p-6 relative self-stretch w-full flex-[0_0_auto] bg-white rounded-2xl border border-solid border-[#c3c6d0] shadow-[0px_1px_2px_#0000000d]">
        <div className="flex flex-col items-start relative self-stretch w-full flex-[0_0_auto]">
          <h3
            id={timeGroupId}
            className="relative flex items-center self-stretch mt-[-1.00px] [font-family:'Be_Vietnam_Pro-SemiBold',Helvetica] font-semibold text-[#173b6c] text-xl tracking-[0] leading-[26px]"
          >
            Time Available
          </h3>
        </div>
        <div
          role="radiogroup"
          aria-labelledby={timeGroupId}
          className="relative self-stretch w-full h-[83.19px]"
        >
          {timeOptions.map((option) => {
            const isSelected = selectedTime === option.id;

            return (
              <button
                key={option.id}
                type="button"
                role="radio"
                aria-checked={isSelected}
                onClick={() => setSelectedTime(option.id)}
                className={
                  isSelected
                    ? "all-[unset] box-border inline-flex flex-col items-center justify-center px-4 py-2 absolute top-0 left-[107px] bg-[#d6e3ff] rounded-full border border-solid border-[#173b6c]"
                    : `all-[unset] box-border ${option.buttonClassName}`
                }
              >
                <div
                  className={
                    isSelected
                      ? "relative flex items-center justify-center w-[93.47px] h-5 [font-family:'Be_Vietnam_Pro-Medium',Helvetica] font-medium text-[#173b6c] text-sm text-center tracking-[0] leading-[19.6px] whitespace-nowrap"
                      : option.textClassName
                  }
                >
                  {option.label}
                </div>
              </button>
            );
          })}
        </div>
      </section>
      <div className="flex flex-col items-start pt-4 pb-0 px-0 relative self-stretch w-full flex-[0_0_auto]">
        <div className="flex flex-col items-start gap-4 pt-0 pb-8 px-0 relative self-stretch w-full flex-[0_0_auto]">
          <button
            type="button"
            className="all-[unset] box-border flex h-[60px] items-center justify-center gap-2 pt-[16.5px] pb-[17.5px] px-0 relative self-stretch w-full bg-[#ff6a3d] rounded-xl cursor-pointer"
            aria-label="Get recommendations"
          >
            <div className="absolute w-full top-0 left-0 h-[60px] bg-[#ffffff01] rounded-xl shadow-[0px_2px_4px_-2px_#0000001a,0px_4px_6px_-1px_#0000001a]" />
            <div className="relative flex items-center justify-center w-[226.7px] h-[26px] mt-[-1.00px] [font-family:'Be_Vietnam_Pro-SemiBold',Helvetica] font-semibold text-white text-xl text-center tracking-[0] leading-[26px] whitespace-nowrap">
              Get Recommendations
            </div>
            <div className="inline-flex flex-col items-center relative flex-[0_0_auto]">
              <img
                className="relative w-4 h-4"
                alt=""
                aria-hidden="true"
                src={icon9}
              />
            </div>
          </button>
          <button
            type="button"
            className="all-[unset] box-border flex flex-col items-center justify-center px-0 py-3 relative self-stretch w-full flex-[0_0_auto] rounded-xl cursor-pointer"
          >
            <div className="relative flex items-center justify-center w-[109.89px] h-[27px] mt-[-1.00px] [font-family:'Be_Vietnam_Pro-Medium',Helvetica] font-medium text-[#173b6c] text-lg text-center tracking-[0] leading-[27px] whitespace-nowrap">
              Skip for now
            </div>
          </button>
        </div>
      </div>
    </section>
  );
};
