import argparse
import csv
import random
from pathlib import Path


SITUATIONS = [
    "walking together",
    "standing and chatting",
    "waiting at a crosswalk",
    "walking through a shopping street",
    "walking on a station concourse",
    "waiting near a bus stop",
    "crossing a city street",
    "strolling in a park",
    "gathering near a plaza",
    "walking along a sidewalk",
    "standing in front of storefronts",
    "entering or leaving an office building",
    "walking through a market area",
    "waiting in an outdoor queue",
    "moving through a public square",
    "walking near a waterfront promenade",
    "standing near a campus walkway",
    "walking through a residential street",
    "taking a casual group walk",
    "waiting near a train platform entrance",
]

ETHNICITIES = [
    "East Asian",
    "South Asian",
    "Southeast Asian",
    "White",
    "Black",
    "Latino",
    "Middle Eastern",
    "mixed-ethnicity",
]

GENDER_MIXES = [
    "all male",
    "all female",
    "mixed gender",
    "mostly male with a few women",
    "mostly female with a few men",
]

TIMES_OF_DAY = [
    "early morning",
    "morning",
    "late morning",
    "noon",
    "afternoon",
    "late afternoon",
    "golden hour",
    "evening",
    "night",
]

LOCATIONS = [
    "a downtown street",
    "a shopping district",
    "a train station entrance",
    "a station concourse",
    "a pedestrian crossing",
    "a city sidewalk",
    "a public plaza",
    "an office district",
    "a park walkway",
    "a waterfront promenade",
    "a market street",
    "a residential neighborhood",
    "a university campus path",
    "a bus terminal area",
    "an outdoor food court area",
    "a suburban shopping mall exterior",
    "a tourist street",
    "a small town main street",
    "a business park walkway",
    "a riverside path",
]

WEATHER_LIGHTING = [
    "clear weather",
    "slightly cloudy weather",
    "overcast weather",
    "bright natural light",
    "soft diffused light",
    "warm sunset light",
    "cool evening light",
    "nighttime city lighting",
]

CAMERA_VIEWS = [
    "eye-level view",
    "slightly elevated view",
    "street-level perspective",
    "natural candid composition",
]

CLOTHING_STYLES = [
    "casual everyday clothing",
    "light business casual clothing",
    "summer casual clothing",
    "spring street fashion",
    "simple everyday outfits",
]

BACKGROUND_MOODS = [
    "clean urban background",
    "ordinary public environment",
    "busy but readable background",
    "natural everyday atmosphere",
]

QUALITY_TAGS = [
    "realistic photo",
    "high detail",
    "natural human proportions",
    "sharp focus",
]

NEGATIVE_LIKE_TAGS = [
    "no text",
    "no watermark",
    "no collage",
    "no extra limbs",
    "no duplicated people",
]


def person_phrase(n: int) -> str:
    return "1 person" if n == 1 else f"{n} people"


def build_prompt(rng: random.Random, min_people: int, max_people: int) -> dict:
    n = rng.randint(min_people, max_people)

    ethnicity = rng.choice(ETHNICITIES)
    gender_mix = rng.choice(GENDER_MIXES)
    situation = rng.choice(SITUATIONS)
    time_of_day = rng.choice(TIMES_OF_DAY)
    location = rng.choice(LOCATIONS)
    weather = rng.choice(WEATHER_LIGHTING)
    camera_view = rng.choice(CAMERA_VIEWS)
    clothing = rng.choice(CLOTHING_STYLES)
    mood = rng.choice(BACKGROUND_MOODS)

    prompt = (
        f"A {', '.join(QUALITY_TAGS)} showing {person_phrase(n)} of {ethnicity} adults, "
        f"{gender_mix}, {situation} in {location} during {time_of_day}, with {weather}, "
        f"{camera_view}, {clothing}, {mood}. "
        f"All {person_phrase(n)} should be clearly visible and individually countable, "
        f"with minimal occlusion, natural poses, and realistic spacing. "
        f"Suitable for a people-counting dataset. "
        f"{', '.join(NEGATIVE_LIKE_TAGS)}."
    )

    return {
        "num_people": n,
        "ethnicity": ethnicity,
        "gender_mix": gender_mix,
        "situation": situation,
        "time_of_day": time_of_day,
        "location": location,
        "weather_lighting": weather,
        "camera_view": camera_view,
        "clothing_style": clothing,
        "background_mood": mood,
        "prompt": prompt,
    }


def generate_unique_prompts(count: int, min_people: int, max_people: int, seed: int):
    rng = random.Random(seed)
    rows = []
    seen = set()

    max_trials = count * 50
    trials = 0

    while len(rows) < count and trials < max_trials:
        trials += 1
        row = build_prompt(rng, min_people, max_people)

        key = (
            row["num_people"],
            row["ethnicity"],
            row["gender_mix"],
            row["situation"],
            row["time_of_day"],
            row["location"],
            row["weather_lighting"],
            row["camera_view"],
            row["clothing_style"],
            row["background_mood"],
        )

        if key in seen:
            continue

        seen.add(key)
        row["id"] = len(rows) + 1
        rows.append(row)

    if len(rows) < count:
        raise RuntimeError(
            f"Could only generate {len(rows)} unique prompts. "
            f"Try increasing the variety lists or reducing count."
        )

    return rows


def save_csv(rows, out_csv: Path):
    fieldnames = [
        "id",
        "num_people",
        "ethnicity",
        "gender_mix",
        "situation",
        "time_of_day",
        "location",
        "weather_lighting",
        "camera_view",
        "clothing_style",
        "background_mood",
        "prompt",
    ]
    with out_csv.open("w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def save_txt(rows, out_txt: Path):
    with out_txt.open("w", encoding="utf-8") as f:
        for row in rows:
            f.write(f"[{row['id']:03d}] {row['prompt']}\n")


def main():
    parser = argparse.ArgumentParser(
        description="Generate random people-counting prompts."
    )
    parser.add_argument("--count", type=int, default=100, help="Number of prompts")
    parser.add_argument("--min_people", type=int, default=1, help="Minimum people")
    parser.add_argument("--max_people", type=int, default=15, help="Maximum people")
    parser.add_argument("--seed", type=int, default=42, help="Random seed")
    parser.add_argument("--out_dir", type=str, default="generated_prompts", help="Output directory")
    parser.add_argument("--csv_name", type=str, default="people_prompts_100.csv", help="CSV filename")
    parser.add_argument("--txt_name", type=str, default="people_prompts_100.txt", help="TXT filename")
    args = parser.parse_args()

    if args.min_people < 1:
        raise ValueError("--min_people must be >= 1")
    if args.max_people < args.min_people:
        raise ValueError("--max_people must be >= --min_people")

    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    rows = generate_unique_prompts(
        count=args.count,
        min_people=args.min_people,
        max_people=args.max_people,
        seed=args.seed,
    )

    out_csv = out_dir / args.csv_name
    out_txt = out_dir / args.txt_name

    save_csv(rows, out_csv)
    save_txt(rows, out_txt)

    print(f"Generated {len(rows)} prompts.")
    print(f"CSV : {out_csv}")
    print(f"TXT : {out_txt}")

    print("\nSample prompts:")
    for row in rows[:5]:
        print(f"- [{row['id']:03d}] {row['prompt']}")


if __name__ == "__main__":
    main()