const OMDB_API_BASE_URL = 'http://www.omdbapi.com/';

interface OMDBMovieResponse {
  Response: 'True' | 'False';
  Error?: string;
  imdbRating?: string;
}

export const fetchMovieRating = async (
  title: string,
  releaseYear?: number | string
): Promise<string | null> => {
  const apiKey = process.env.EXPO_PUBLIC_OMDB_API_KEY;

  if (!apiKey) {
    throw new Error('Missing EXPO_PUBLIC_OMDB_API_KEY environment variable.');
  }

  const searchParams = new URLSearchParams({
    apikey: apiKey,
    t: title,
  });

  if (releaseYear) {
    searchParams.append('y', String(releaseYear));
  }

  const endpoint = `${OMDB_API_BASE_URL}?${searchParams.toString()}`;

  try {
    const response = await fetch(endpoint, {
      method: 'GET',
      headers: {
        Accept: 'application/json',
      },
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(
        `OMDb request failed: ${response.status} ${response.statusText} - ${errorText}`
      );
    }

    const payload = (await response.json()) as OMDBMovieResponse;

    if (payload.Response === 'False') {
      return null;
    }

    if (!payload.imdbRating || payload.imdbRating === 'N/A') {
      return null;
    }

    return payload.imdbRating;
  } catch (error) {
    console.error('Failed to fetch OMDb movie rating:', error);
    throw error;
  }
};
